const EncryptedFeedbacks = require('../models/encryptedFeedbackModel');
const Classes = require('../models/classModels');
const AiSuggestions = require('../models/aiSuggestionsModel');
const { decrypt } = require('../crypto');

const buildFeedbackPrompt = ({ classId, mentorId, feedbackText, feedbackCount, overallRating }) => {
  return `You are an AI Teaching Performance Analyst.

Your task is to analyze all student feedback for a class and generate professional, constructive, and actionable mentor improvement suggestions.

INPUT DATA:

- Total Feedback Submitted: ${feedbackCount}

FEEDBACK DATA:
${feedbackText}

RATING SUMMARY:

- Overall Rating: ${overallRating}/5

ANALYSIS REQUIREMENTS:
1. Identify the most common positive feedback points.
2. Identify the most common negative feedback points.
3. Detect repeated issues mentioned by multiple students.
4. Perform sentiment analysis:
   - Positive
   - Neutral
   - Negative
5. Identify classroom improvement areas.
6. Generate practical suggestions for the mentor.
7. Mention student engagement observations.
8. Detect if students are struggling with:
   - Pace
   - Clarity
   - Interaction
   - Examples
   - Communication
9. Generate a mentor performance summary.
10. Keep suggestions professional and constructive.

OUTPUT FORMAT (STRICT JSON):
{
  "mentorPerformance": {
    "overallSentiment": "",
    "performanceLevel": "",
    "summary": ""
  },
  "positivePoints": [
    ""
  ],
  "negativePoints": [
    ""
  ],
  "repeatedIssues": [
    ""
  ],
  "studentEngagement": {
    "level": "",
    "observation": ""
  },
  "improvementSuggestions": [
    ""
  ],
  "riskAlerts": [
    ""
  ],
  "finalRecommendation": ""
}

IMPORTANT RULES:
- Do not generate fake data.
- Base conclusions only on provided feedback.
- Suggestions must be short, practical, and actionable.
- Avoid offensive or personal criticism.
- Focus on teaching improvement only.
- If feedback is insufficient, mention low confidence in analysis.`;
};

const analyzeEncryptedFeedback = async (req, res) => {
  try {
    const { classId } = req.body;

    if (!classId) {
      return res.status(400).json({ error: 'classId required' });
    }

    const encryptedRecords = await EncryptedFeedbacks.find();

    const decryptedFeedbacks = [];

    for (const record of encryptedRecords) {
      try {
        const decryptedClassId = decrypt(
          record.encryptedClassId.encryptedData,
          record.encryptedClassId.iv,
          record.encryptedClassId.authTag
        );

        if (decryptedClassId !== classId) {
          continue;
        }

        const decryptedComment = decrypt(
          record.encryptedComment.encryptedData,
          record.encryptedComment.iv,
          record.encryptedComment.authTag
        );

        let decryptedRating = null;
        if (record.encryptedRating) {
          try {
            decryptedRating = Number(
              decrypt(
                record.encryptedRating.encryptedData,
                record.encryptedRating.iv,
                record.encryptedRating.authTag
              )
            );
          } catch (ratingError) {
            decryptedRating = null;
          }
        }

        decryptedFeedbacks.push({
          rating: decryptedRating,
          comment: decryptedComment,
        });
      } catch (decryptError) {
        console.warn('Skipping record that failed to decrypt:', decryptError.message);
      }
    }

    if (decryptedFeedbacks.length === 0) {
      return res.status(404).json({ error: 'no feedbacks found for classId' });
    }

    const classDoc = await Classes.findOne({ classId });
    const mentorId = classDoc ? classDoc.mentorId : undefined;

    const feedbackText = decryptedFeedbacks
      .map((entry, index) => `Feedback ${index + 1} (rating: ${entry.rating ?? 'N/A'}): ${entry.comment}`)
      .join('\n\n');

    const ratingValues = decryptedFeedbacks
      .map((entry) => entry.rating)
      .filter((rating) => Number.isFinite(rating));

    const overallRating = ratingValues.length
      ? (ratingValues.reduce((sum, rating) => sum + rating, 0) / ratingValues.length).toFixed(1)
      : 'N/A';

    const prompt = buildFeedbackPrompt({
      classId,
      mentorId,
      feedbackText,
      feedbackCount: decryptedFeedbacks.length,
      overallRating,
    });

    const { GoogleGenAI } = await import('@google/genai');
    const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: prompt,
    });

    const rawResponse = response.text || '';
    const cleanedResponse = rawResponse.replace(/```json/g, '').replace(/```/g, '').trim();

    let analysis = null;
    try {
      analysis = JSON.parse(cleanedResponse);
    } catch (parseError) {
      const savedRaw = await AiSuggestions.create({
        classId,
        mentorId,
        prompt,
        rawResponse,
      });

      return res.status(200).json({
        success: true,
        message: 'AI response saved, but JSON parsing failed',
        saved: savedRaw,
        rawResponse,
      });
    }

    const saved = await AiSuggestions.create({
      classId,
      mentorId,
      prompt,
      rawResponse,
      analysis,
      overallRating,
      feedbackCount: decryptedFeedbacks.length,
    });

    return res.json({
      success: true,
      message: 'AI suggestions generated and stored',
      saved,
      analysis,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  }
};

module.exports = {
  analyzeEncryptedFeedback,
};

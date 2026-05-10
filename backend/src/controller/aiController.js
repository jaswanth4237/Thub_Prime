const EncryptedFeedbacks = require('../models/encryptedFeedbackModel');
const Classes = require('../models/classModels');
const AiSuggestions = require('../models/aiSuggestionsModel');
const Attendance = require('../models/attendanceModels');
const { decrypt } = require('../crypto');

let GoogleGenAIClient = null;
try {
  ({ GoogleGenAI: GoogleGenAIClient } = require('@google/genai'));
} catch (packageError) {
  GoogleGenAIClient = null;
}

const buildFallbackAnalysis = ({ feedbacks, feedbackCount, overallRating }) => {
  const comments = feedbacks
    .map((f) => (f && f.comment ? String(f.comment).trim() : ''))
    .filter((c) => c.length > 0);

  const stopwords = new Set(['the', 'and', 'a', 'an', 'to', 'is', 'it', 'of', 'for', 'on', 'in', 'that', 'this', 'with', 'as', 'are', 'was', 'but', 'be', 'or', 'have', 'has', 'i', 'we', 'you', 'they']);

  const positiveLexicon = ['good', 'great', 'excellent', 'love', 'liked', 'helpful', 'clear', 'understand', 'engaging', 'interesting', 'useful', 'practical', 'easy'];
  const negativeLexicon = ['bad', 'poor', 'boring', 'confusing', 'confused', 'unclear', 'fast', 'slow', 'difficult', 'hard', 'lost', 'frustrat', 'disappoint', 'skip', 'unclear', 'boring'];

  const wordCounts = new Map();
  const positivePoints = [];
  const negativePoints = [];
  const repeatedIssues = [];

  for (const c of comments) {
    const words = c
      .toLowerCase()
      .replace(/[\W_]+/g, ' ')
      .split(/\s+/)
      .filter((w) => w && !stopwords.has(w));

    const seen = new Set();
    for (const w of words) {
      wordCounts.set(w, (wordCounts.get(w) || 0) + 1);
      if (!seen.has(w)) {
        if (positiveLexicon.includes(w)) positivePoints.push(c);
        if (negativeLexicon.includes(w)) negativePoints.push(c);
        seen.add(w);
      }
    }
  }

  const sortedKeywords = Array.from(wordCounts.entries())
    .sort((a, b) => b[1] - a[1])
    .map((e) => e[0]);

  const keywordSuggestionMap = {
    pace: 'Adjust pacing: add quick checks and slow down on complex topics.',
    unclear: 'Clarify objectives and provide short summaries after each section.',
    example: 'Add more real-world examples and step-by-step demos.',
    interactive: 'Include short interactive exercises and polls to boost engagement.',
    question: 'Pause for Q&A and invite students to ask targeted questions.',
    boring: 'Introduce varied activities and shorten monologues to keep attention.'
  };

  const suggestedSet = new Set();
  for (const kw of sortedKeywords.slice(0, 12)) {
    for (const key of Object.keys(keywordSuggestionMap)) {
      if (kw.includes(key)) {
        suggestedSet.add(keywordSuggestionMap[key]);
        repeatedIssues.push(`Issue: ${kw}`);
      }
    }
  }

  if (sortedKeywords.length === 0) {
    suggestedSet.add('Collect more feedback and run quick in-class polls to identify pain points.');
  }

  let suggestions = Array.from(suggestedSet);

  // If no mapped suggestions found, add reasonable defaults based on comment signals
  if (suggestions.length === 0) {
    if (negativePoints.length > 0) {
      suggestions.push('Clarify core objectives and provide short summaries after key sections.');
    }
    suggestions.push('Add more real-world examples and step-by-step demos.');
    suggestions.push('Include short interactive exercises and polls to boost engagement.');
  }

  const ratingNum = Number.isFinite(Number(overallRating)) ? Number(overallRating) : null;
  let overallSentiment = 'Mixed';
  if (ratingNum !== null) {
    overallSentiment = ratingNum >= 4 ? 'Positive' : ratingNum >= 3 ? 'Mixed' : 'Negative';
  } else if (positivePoints.length > negativePoints.length) {
    overallSentiment = 'Positive';
  } else if (negativePoints.length > positivePoints.length) {
    overallSentiment = 'Negative';
  }

  const riskAlerts = [];

  return {
    mentorPerformance: {
      overallSentiment,
      performanceLevel: ratingNum !== null ? (ratingNum >= 4 ? 'Strong' : ratingNum >= 3 ? 'Developing' : 'Needs Attention') : 'Unknown',
      summary: `Analysis based on ${comments.length} comment(s) and ${feedbackCount} total feedback(s).`,
    },
    positivePoints: positivePoints.length ? Array.from(new Set(positivePoints)).slice(0, 5) : ['No clear positive patterns detected from comments.'],
    negativePoints: negativePoints.length ? Array.from(new Set(negativePoints)).slice(0, 5) : ['No strong negative pattern detected from the submitted comments.'],
    repeatedIssues: repeatedIssues.length ? Array.from(new Set(repeatedIssues)) : ['No repeated issues detected.'],
    studentEngagement: {
      level: ratingNum !== null ? (ratingNum >= 4 ? 'Good' : 'Moderate') : (positivePoints.length > negativePoints.length ? 'Good' : 'Moderate'),
      observation: `Top keywords: ${sortedKeywords.slice(0, 6).join(', ')}`,
    },
    improvementSuggestions: suggestions.slice(0, 5),
    riskAlerts: riskAlerts.length ? riskAlerts : ['No urgent risk detected.'],
    finalRecommendation: 'Prioritize the top suggestions and gather more targeted feedback next session.',
    overallRating: ratingNum !== null ? ratingNum.toFixed(1) : overallRating,
  };
};



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
        if (!record?.encryptedClassId?.encryptedData || !record?.encryptedComment?.encryptedData) {
          continue;
        }

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

    const extractJson = (text) => {
      if (!text || typeof text !== 'string') return null;
      const cleaned = text.replace(/```json/g, '').replace(/```/g, '').trim();
      try {
        return JSON.parse(cleaned);
      } catch (e) {
        const match = cleaned.match(/\{[\s\S]*\}/);
        if (match) {
          try {
            return JSON.parse(match[0]);
          } catch (e2) {
            return null;
          }
        }
        return null;
      }
    };

    let rawResponse = '';
    let analysis = null;

    try {
      const apiKey = process.env.GEMINI_API_KEY;

      if (!GoogleGenAIClient || !apiKey) {
        throw new Error('Gemini client unavailable');
      }

      const ai = new GoogleGenAIClient({ apiKey });
      const response = await ai.models.generateContent({
        model: 'gemini-3-flash-preview',
        contents: prompt,
      });

      rawResponse = response.text || '';
      analysis = extractJson(rawResponse);

      if (!analysis) {
        throw new Error('AI returned non-JSON');
      }
    } catch (aiError) {
      // Try OpenAI fallback if configured
      if (process.env.OPENAI_API_KEY) {
        try {
          const openaiResp = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
            },
            body: JSON.stringify({
              model: process.env.OPENAI_MODEL || 'gpt-3.5-turbo',
              messages: [
                { role: 'system', content: 'You are an AI Teaching Performance Analyst. Produce STRICT JSON matching the schema described in the prompt.' },
                { role: 'user', content: prompt },
              ],
              max_tokens: 800,
              temperature: 0.2,
            }),
          });

          const openaiBody = await openaiResp.json();
          rawResponse = (openaiBody?.choices && openaiBody.choices[0] && openaiBody.choices[0].message && openaiBody.choices[0].message.content) || '';
          analysis = extractJson(rawResponse);
        } catch (openAiErr) {
          console.warn('OpenAI fallback failed:', openAiErr?.message || openAiErr);
        }
      }

      if (!analysis) {
        analysis = buildFallbackAnalysis({
          feedbacks: decryptedFeedbacks,
          feedbackCount: decryptedFeedbacks.length,
          overallRating,
        });
        rawResponse = JSON.stringify(analysis, null, 2);
      }
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

    const totalStudentsArr = await Attendance.distinct('studentId', { classId });
    const totalStudents = totalStudentsArr.length;

    return res.status(200).json({
      ...analysis,
      totalStudents,
      feedbackCount: decryptedFeedbacks.length,
      overallRating
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  }
};

module.exports = {
  analyzeEncryptedFeedback,
};

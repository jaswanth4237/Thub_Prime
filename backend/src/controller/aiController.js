import express from "express";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

app.post("/analyze-feedback", async (req, res) => {

  try { 

    const { feedback } = req.body;

    const prompt =

      `You are an AI Teaching Performance Analyst.

      Your task is to analyze all student feedback for a class and generate professional, constructive, and actionable mentor improvement suggestions.

      INPUT DATA:
      - Subject Name: {{subject}}
      - Mentor Name: {{mentorName}}
      - Class Name: {{className}}
      - Total Students Attended: {{attendanceCount}}
      - Total Feedback Submitted: {{feedbackCount}}

      Feedback:"${feedback}"

      RATING SUMMARY:
      - Teaching Clarity: {{clarityRating}}/5
      - Interaction Level: {{interactionRating}}/5
      - Practical Examples: {{practicalRating}}/5
      - Communication: {{communicationRating}}/5
      - Overall Rating: {{overallRating}}/5

      ANALYSIS REQUIREMENTS:
      1. Identify the most common positive feedback points.
          // 1.1 If the feedback not contain the positive feedback then don't give positive points in the output.
      2. Identify the most common negative feedback points.
          // 2.1 If the feedback not contain the negative feedback then don't give negative points in the output.
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
      - Suggestions must be short, practical, actionable and human made suggestions.
      - Avoid offensive or personal criticism.
      - Focus on teaching improvement only.
      - If feedback is insufficient, mention low confidence in analysis.
    `;

    const response = await ai.models.generateContent({
      model: "gemini-3-flash-preview",
      contents: prompt,
    });

    const text = response.text;

    const cleanedText = text
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    res.json(JSON.parse(cleanedText));

  } catch (error) {

    console.log(error);

    res.status(500).json({
      error: error.message,
    });
  }
});

app.listen(5000, () => {
  console.log("Server running on port 5000");
});
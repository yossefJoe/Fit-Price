import 'package:flutter_dotenv/flutter_dotenv.dart';

String myApiKey = 'AIzaSyDxaapuPeMvcbzgm0YOW-YLf9qzdegMi2I';
String promtText = """ You are an AI assistant that analyzes product images for a marketplace app.

Your task:
- Analyze the provided image
- Identify the product type
- Estimate its condition
- Detect visible issues if any
- Suggest a reasonable price range in USD
- Generate a short professional title

Rules:
- Respond with VALID JSON ONLY
- Do NOT include explanations or extra text
- If something is unclear, make a best guess and lower the confidence score

JSON schema:
{
  "title": string,
  "category": string,
  "condition": string,
  "issues": array of strings,
  "suggested_price_range": {
    "min": number,
    "max": number
  },
  "confidence_score": number between 0 and 1
}
""";


String cloudName = 'dnxkdxdvj';
String uploadPreset = 'chatgpt_images';
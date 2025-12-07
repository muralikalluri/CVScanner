package com.cvscreener.scoring.listener;

import com.cvscreener.scoring.model.CvResult;
import com.cvscreener.scoring.repository.CvResultRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.ChatClient;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.ollama.api.OllamaOptions;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class CvEventListener {

    private final ChatClient chatClient;
    private final CvResultRepository cvResultRepository;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "cv-uploaded-event", groupId = "ai-scoring-group")
    public void handleCvUpload(String message) {
        log.info("Received Kafka Message: {}", message);
        try {
            JsonNode node = objectMapper.readTree(message);
            Long cvId = node.get("cvId").asLong();
            String content = node.get("content").asText();

            // Simple Prompt Logic (Simplistic for MVP)
            String prompt = """
                    You are an HR Assistant. Analyze the following CV content against a Generic Java Developer Job Description.
                    Provide a JSON response with:
                    - score (integer 0-100)
                    - summary (string)
                    - analysis (string details)
                    
                    CV Content:
                    """ + content;

            PromptTemplate promptTemplate = new PromptTemplate(prompt);
            Prompt chatPrompt = new Prompt(promptTemplate.createMessage().getContent(),
                    OllamaOptions.create().withModel("tinyllama"));
            String aiResponse = chatClient.call(chatPrompt).getResult().getOutput().getContent();
            log.info("AI Response: {}", aiResponse);

            // Mock Parsing logic for now (assuming AI returns JSON string or text)
            // In a real app, we'd force JSON output via prompt engineering and parse it.
            // For now, let's just save the raw response as summary and a dummy score.
            
            CvResult result = new CvResult();
            result.setCvId(cvId);
            result.setSummary(aiResponse);
            // Attempt to extract score if possible, else random or 0
            result.setScore(50); // Placeholder
            result.setMatchAnalysis("AI Processed");
            
            cvResultRepository.save(result);
            log.info("Saved Result for CV ID: {}", cvId);

        } catch (Exception e) {
            log.error("Error processing message", e);
        }
    }
}

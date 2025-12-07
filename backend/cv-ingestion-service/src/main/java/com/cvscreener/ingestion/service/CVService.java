package com.cvscreener.ingestion.service;

import com.cvscreener.ingestion.model.CV;
import com.cvscreener.ingestion.repository.CVRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class CVService {

    private final CVRepository cvRepository;
    private final KafkaTemplate<String, String> kafkaTemplate;

    public CV uploadCV(MultipartFile file) throws IOException {
        String text = extractText(file);
        
        CV cv = new CV();
        cv.setFileName(file.getOriginalFilename());
        cv.setUploadDate(LocalDateTime.now());
        cv.setContent(text);
        
        CV savedCv = cvRepository.save(cv);
        
        // Publish Event
        // Ideally we publish a DTO, here publishing JSON string simplistic for demo
        String eventPayload = String.format("{\"cvId\": %d, \"content\": \"%s\"}", savedCv.getId(), escapeJson(text));
        kafkaTemplate.send("cv-uploaded-event", String.valueOf(savedCv.getId()), eventPayload);
        log.info("Published cv-uploaded-event for CV ID: {}", savedCv.getId());
        
        return savedCv;
    }

    private String extractText(MultipartFile file) throws IOException {
        try (PDDocument document = PDDocument.load(file.getInputStream())) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        }
    }
    
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}

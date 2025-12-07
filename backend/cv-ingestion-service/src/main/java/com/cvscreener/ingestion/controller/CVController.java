package com.cvscreener.ingestion.controller;

import com.cvscreener.ingestion.model.CV;
import com.cvscreener.ingestion.service.CVService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/cv")
@RequiredArgsConstructor
public class CVController {

    private final CVService cvService;

    @PostMapping("/upload")
    public ResponseEntity<CV> uploadCV(@RequestParam("file") MultipartFile file) {
        try {
            CV cv = cvService.uploadCV(file);
            return ResponseEntity.ok(cv);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}

package com.cvscreener.scoring.controller;

import com.cvscreener.scoring.model.CvResult;
import com.cvscreener.scoring.repository.CvResultRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/results")
@RequiredArgsConstructor
public class ResultController {

    private final CvResultRepository repository;

    @GetMapping("/{cvId}")
    public ResponseEntity<CvResult> getResult(@PathVariable Long cvId) {
        System.out.println("ResultController hit for ID: " + cvId);
        return repository.findByCvId(cvId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}

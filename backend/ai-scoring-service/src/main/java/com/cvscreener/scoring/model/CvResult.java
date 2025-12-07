package com.cvscreener.scoring.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class CvResult {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long cvId; // Reference to CV Ingestion Service ID
    private Integer score; // 0-100
    
    @Lob
    @Column(length = 100000)
    private String summary;
    
    @Lob
    @Column(length = 100000)
    private String matchAnalysis;
}

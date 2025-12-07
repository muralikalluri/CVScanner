package com.cvscreener.ingestion.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
public class CV {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String fileName;
    private String candidateName; // Optional, extracted or input
    private LocalDateTime uploadDate;
    
    @Lob
    @Column(length = 100000)
    private String content; // Extracted Text
}

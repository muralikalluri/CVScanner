package com.cvscreener.scoring.repository;

import com.cvscreener.scoring.model.CvResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CvResultRepository extends JpaRepository<CvResult, Long> {
    Optional<CvResult> findByCvId(Long cvId);
}

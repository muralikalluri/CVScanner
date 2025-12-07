import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface CV {
    id: number;
    fileName: string;
    uploadDate: string;
}

export interface CvResult {
    id: number;
    cvId: number;
    score: number;
    summary: string;
    matchAnalysis: string;
}

@Injectable({
    providedIn: 'root'
})
export class CvService {
    private apiUrl = 'http://localhost:8080/api'; // Through Gateway

    constructor(private http: HttpClient) { }

    uploadCv(file: File): Observable<CV> {
        const formData = new FormData();
        formData.append('file', file);
        return this.http.post<CV>(`${this.apiUrl}/cv/upload`, formData);
    }

    getResult(cvId: number): Observable<CvResult> {
        return this.http.get<CvResult>(`${this.apiUrl}/ai/results/${cvId}`);
    }
}

import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { CvService, CvResult } from './cv.service';
import { delay, switchMap, retryWhen, take, tap } from 'rxjs/operators';
import { timer } from 'rxjs';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, HttpClientModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  providers: [CvService]
})
export class AppComponent {
  selectedFile: File | null = null;
  isDragging = false;
  isUploading = false;
  isProcessing = false;
  currentResult: CvResult | null = null;

  constructor(private cvService: CvService) { }

  onDragOver(event: DragEvent) {
    event.preventDefault();
    this.isDragging = true;
  }

  onDragLeave(event: DragEvent) {
    event.preventDefault();
    this.isDragging = false;
  }

  onDrop(event: DragEvent) {
    event.preventDefault();
    this.isDragging = false;
    if (event.dataTransfer?.files.length) {
      this.selectedFile = event.dataTransfer.files[0];
    }
  }

  onFileSelected(event: any) {
    if (event.target.files.length) {
      this.selectedFile = event.target.files[0];
    }
  }

  upload() {
    if (!this.selectedFile) return;

    this.isUploading = true;
    this.currentResult = null;

    this.cvService.uploadCv(this.selectedFile).subscribe({
      next: (cv) => {
        this.isUploading = false;
        this.isProcessing = true;
        this.pollForResult(cv.id);
      },
      error: (err) => {
        console.error(err);
        this.isUploading = false;
        alert('Upload failed!');
      }
    });
  }

  pollForResult(cvId: number) {
    // Simple polling: Try 5 times every 2 seconds
    timer(1000, 3000).pipe(
      switchMap(() => this.cvService.getResult(cvId)),
      retryWhen(errors => errors.pipe(delay(3000), take(100))),
      take(1) // Stop once we get a success result? Actually retryWhen handles errors, take(1) handles first success
    ).subscribe({
      next: (result) => {
        this.currentResult = result;
        this.isProcessing = false;
      },
      error: (err) => {
        // After retries exhausted
        this.isProcessing = false;
        // It might be that 404 is treated as error, so we need to handle "not ready" gracefully in service or here.
        // For simplistic demo, we assume AI is fast enough or user retries.
      }
    });
  }
}

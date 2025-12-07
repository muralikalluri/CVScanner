# CV Screener Application

A Microservices-based application that parses PDF Resumes/CVs and uses Generative AI to score them against job descriptions.

## 🏗️ Architecture

The application handles CV analysis through the following flow:
1.  **Frontend (Angular)**: User uploads PDF.
2.  **API Gateway**: Routes request to backend services.
3.  **CV Ingestion Service**: Parses PDF, saves text, and publishes a Kafka Event.
4.  **AI Scoring Service**: Consumes the event, sends context to an LLM (Ollama/AWS Bedrock), and saves the result.
5.  **Frontend**: Polls for the result and displays the Score and Summary.

### Tech Stack
-   **Backend**: Java 17, Spring Boot 3.2, Spring Cloud (Gateway, Eureka).
-   **AI**: Spring AI (Ollama for Local, Bedrock for Cloud).
-   **Messaging**: Apache Kafka (on AWS EC2).
-   **Frontend**: Angular 17+, TailwindCSS.
-   **Database**: H2 (In-memory for demo).

---

## 🚀 Prerequisites

1.  **Java 17+**
2.  **Maven 3.8+**
3.  **Node.js 18+** & NPM
4.  **Ollama** (Running locally).
5.  **AWS Account** (For Kafka infrastructure).

---

## 🛠️ Setup Instructions

### 1. Infrastructure (Kafka)
You need a running Kafka broker. Since Docker is restricted locally, we use AWS EC2.

**Option A: AWS CloudShell (Recommended)**
1.  Login to AWS Console and open CloudShell.
2.  Upload/Paste the scripts from `infrastructure-aws/`.
3.  Run: `./setup-kafka-ec2.sh <your-key-pair-name>`
4.  **Note the IP Address** (e.g., `54.123.45.67`).

**Option B: Local PowerShell**
1.  Navigate to `infrastructure-aws/`.
2.  Run: `.\setup-kafka-ec2.ps1 -KeyPairName "your-key-pair-name"`

**Configuration**:
Update `application.yml` in `cv-ingestion-service` and `ai-scoring-service`:
```yaml
spring:
  kafka:
    bootstrap-servers: 54.123.45.67:9092 # Replace with your EC2 IP
```

### 2. AI Setup (Local)
1.  Install [Ollama](https://ollama.com/).
2.  Pull the model (we use `tinyllama` for speed, or `gemma2` for quality).
    ```bash
    ollama serve
    # In another terminal
    ollama pull tinyllama
    ```

---

## ▶️ Running the Application

Open 4 separate terminals. Start them in this order:

**1. Discovery Service**
```bash
cd backend/discovery-service
mvn spring-boot:run
```
_Verify at [http://localhost:8761](http://localhost:8761)_

**2. API Gateway**
```bash
cd backend/api-gateway
mvn spring-boot:run
```
_Verify at [http://localhost:8080](http://localhost:8080)_

**3. CV Ingestion Service**
```bash
cd backend/cv-ingestion-service
mvn spring-boot:run
```

**4. AI Scoring Service**
```bash
cd backend/ai-scoring-service
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

**5. Frontend**
```bash
cd frontend/cv-screener-app
npm install # First time only
npm start
```
_Verify at [http://localhost:4200](http://localhost:4200)_

---

## 📝 Usage

1.  Open the App at [http://localhost:4200](http://localhost:4200).
2.  **Drag & Drop** a PDF Resume file.
3.  Click **Analyze CV**.
4.  The system will process the file (Time depends on your local CPU/GPU).
5.  View the **Match Score** and **AI Summary**.

# GitOps-Driven CI/CD Pipeline for CRUD Application Deployment on Kubernetes Cluster with Amazon EC2

## Repository for Kubernetes Manifests
The Kubernetes manifests for this project:  
[https://github.com/Sarang095/kube-manifests](https://github.com/Sarang095/kube-manifests)

## Overview
This project demonstrates the creation of a **GitOps-driven CI/CD pipeline** for deploying a **CRUD** application on **AWS EC2** using **Kubernetes**. The solution integrates **Jenkins** for continuous integration and **ArgoCD** for GitOps-based continuous deployment, **SonarQube** for code quality analysis, **Nexus Sonatype Repository** for versioned artifact storage, and **Trivy** for vulnerability scanning of Docker images and Kubernetes configurations. **Principle of Least Privilege (PoLP)** is enforced at both the **container** and **cluster** levels to minimize security risks.

## Technologies Used
- **GitOps** with **ArgoCD** for deployment automation
- **Jenkins** for Continuous Integration (CI)
- **SonarQube** for static code analysis with quality gate support
- **Trivy** for Docker image and Kubernetes configuration vulnerability scanning
- **AWS EC2** for hosting the Kubernetes cluster
- **KOPS** for Kubernetes cluster provisioning on AWS
- **Provisioned** SonarQube, Nexus and Jenkins Server using Bash Scripts on Amazon EC2
- **Principle of Least Privilege (PoLP)** to minimize attack surfaces
- **Slack** integrated for build faliure alerts   

## Project Workflow
1. **CI/CD Pipeline**:
   - **Provisioned** SonarQube, Nexus and Jenkins Server using Bash Scripts on Amazon EC2.
   - **Jenkins** handles the continuous integration, triggering build and test processes on code commit.
   - **SonarQube Server** analyzes the code, generating reports for code quality, including **Checkstyle**, **Surefire**, and **JaCoCo** reports.
   - **Trivy** performs vulnerability scans on Docker images and Kubernetes configurations to ensure there are no critical security risks before deployment.
   - **Nexus Sonatype Repository Server** stores the versioned artifact uploaded by Jenkins CI pipeline.

3. **Deployment**:
   - The application is deployed to **AWS EC2** through a **GitOps-based** pipeline, managed by **ArgoCD**.
   - **Trivy** ensures that container images and Kubernetes configurations are free of vulnerabilities by scanning them as part of the deployment pipeline.

4. **Security**:
   - **PoLP** is applied at both **container** and **cluster** levels, ensuring minimal access privileges and reducing the attack surface of the deployment environment.
   - The Kubernetes cluster is provisioned and managed using **KOPS** on **AWS EC2** to provide scalability and resilience with secure access.
  
5. **Docker Image Optimization**
   - Optimized the Docker image using multi-stage builds and Alpine base images,and layer optimizations reducing its size by **50%-70%**.

## Security Considerations
- **Principle of Least Privilege (PoLP)** has been implemented at the **container** and **cluster** levels to minimize risk by limiting the privileges granted to users and components.
- **Trivy** is used for intermidiate docker image scanning, and Kubernetes configurations are also scanned for analysing security risks before deployment.

## Project Snapshots
**Jenkins Pipeline Execution**
![Screenshot 2024-11-16 215108](https://github.com/user-attachments/assets/48486fdf-5cb5-408a-8d64-a60d4fcf8f70)

**Application Status on ArgoCD UI**
![Screenshot 2024-11-16 214258](https://github.com/user-attachments/assets/7c58dae3-cc98-4d9d-9dab-090a2b61e98c)

**Nexus Repository**
![Screenshot 2024-11-16 185629](https://github.com/user-attachments/assets/4dbaceb9-55b3-4b26-b9a6-06dd6a2e3d9e)

**SonarQube Analysis Report**
![Screenshot 2024-11-16 215135](https://github.com/user-attachments/assets/6db1f0a2-e1c2-43bf-b03f-f5864e39d460)

**Slack Notification**
![Screenshot 2024-11-16 214849](https://github.com/user-attachments/assets/cc99148c-1dcd-471a-ba6a-a4e498f38925)

**Testing**
![Screenshot from 2024-09-30 18-21-36](https://github.com/user-attachments/assets/eea6b5a5-9182-4e9b-9bee-5fa8bd9efd0b)

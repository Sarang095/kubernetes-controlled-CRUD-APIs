# GitOps-Driven CI/CD Pipeline for CRUD Application Deployment on Kubernetes Cluster with Amazon EC2

## Repository for Kubernetes Manifests
The Kubernetes manifests for this project are available at:  
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
- **Principle of Least Privilege (PoLP)** to minimize attack surfaces
- **Slack** integrated for build faliure alerts   

## Project Workflow
1. **CI/CD Pipeline**:
   - **Jenkins** handles the continuous integration, triggering build and test processes on code commit.
   - **SonarQube Server** analyzes the code, generating reports for code quality, including **Checkstyle**, **Surefire**, and **JaCoCo** reports.
   - **Trivy** performs vulnerability scans on Docker images and Kubernetes configurations to ensure there are no critical security risks before deployment.
   - **Nexus Sonatype Repository Server** stores the versioned artifact uploaded by Jenkins CI pipeline.

2. **Deployment**:
   - The application is deployed to **AWS EC2** through a **GitOps-based** pipeline, managed by **ArgoCD**.
   - **Trivy** ensures that container images and Kubernetes configurations are free of vulnerabilities by scanning them as part of the deployment pipeline.

3. **Security**:
   - **PoLP** is applied at both **container** and **cluster** levels, ensuring minimal access privileges and reducing the attack surface of the deployment environment.
   - The Kubernetes cluster is provisioned and managed using **KOPS** on **AWS EC2** to provide scalability and resilience with secure access.
  
4. **Docker Image Optimization**
   - Optimized the Docker image using multi-stage builds and Alpine base images,and layer optimizations reducing its size by **50%-70%**.

## Security Considerations
- **Principle of Least Privilege (PoLP)** has been implemented at the **container** and **cluster** levels to minimize risk by limiting the privileges granted to users and components.
- **Trivy** is used for intermidiate docker image scanning, and Kubernetes configurations are also scanned for analysing security risks before deployment.

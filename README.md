# 📘 Project Documentation – Serverless API Using Terraform, AWS & GitHub Actions

## Overview

This project implements a secure, serverless, and scalable API using AWS services such as API Gateway, Lambda, Cognito, and DynamoDB. The API accepts HTTPS POST requests with the following parameters:

* `AppName` (string, max 50 characters)
* `Rating` (number from 1 to 5)
* `Description` (string, max 2000 characters)

The API is authenticated using an access token verified via an external endpoint (configured via environment variable). It accepts requests only from subdomains of `testdevops.com`, and stores data in DynamoDB for efficient retrieval based on `AppName` and creation date.

Infrastructure provisioning is done using Terraform and automated with GitHub Actions CI/CD workflows. The Lambda function is written in Python with built-in logging and CORS support.

---

## ✅ Advantages of the Current Approach

* **Infrastructure as Code:** Terraform enables version-controlled, repeatable infrastructure deployment.
* **Serverless Architecture:** Highly scalable and cost-efficient as you pay only for what you use.
* **CI/CD Automation:** GitHub Actions automate deployment steps, ensuring consistency and speed.
* **Security:** Cognito-based authentication and token validation enhance access control.
* **Domain Restrictions:** CORS policies enforce access from only allowed subdomains.
* **Optimized Data Storage:** DynamoDB designed for efficient lookups by AppName and date.
* **Integrated Logging:** Logs for info, errors, and debug messages are captured within Lambda.

---

## ❌ Disadvantages of the Current Approach

* **Tightly Coupled Deployment:** Lambda code and infrastructure are deployed together using Terraform, making small updates more cumbersome.
* **Basic Logging:** Logs are stored but not structured or monitored centrally through CloudWatch.
* **No DNS Control:** Lacks integration with Route 53 for domain-based routing or failover.
* **No Malicious Request Detection:** There is no WAF or advanced validation for suspicious patterns.
* **Static CORS Handling:** Manually managing allowed origins is error-prone for multiple subdomains.
* **Single Workflow:** One CI/CD pipeline for all components reduces flexibility and modularity.

---

## 🔧 Areas of Improvement

1. **Separate Code and Infra Deployment:** Use AWS SAM for Lambda functions and Terraform for infrastructure to streamline development.
2. **Integrate Route 53:** Add custom domain management for better routing control.
3. **Enhance Observability:** Use CloudWatch Logs and Alarms for centralized log analysis and alerting.
4. **Add WAF:** Implement AWS Web Application Firewall to detect and block malicious requests.
5. **Dynamic CORS:** Automate CORS policy updates for easier maintenance.
6. **Secure Config Management:** Use Parameter Store or Secrets Manager for environment variables and secrets.

---

Let me know if you’d like the corresponding Terraform code, Lambda function (Python), and CI/CD GitHub Actions configuration added to this documentation.

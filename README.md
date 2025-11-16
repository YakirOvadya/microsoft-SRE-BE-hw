# Microsoft SRE/BE Assignment

## Purpose

This repository contains a fully automated, production-ready Container Regestiry enviroment running on Azure ACR, Kubernetes environment running on Azure AKS with RBAC, including:

- Microservices(Pods): Service-A (Bitcoin value fetcher) and Service-B (Hello World service)
- External access through NGINX Ingress Controller
- Secure networking with Network Policies (blocking communication from Service-A to Service-B)
- Liveness & Readiness for production-grade resiliency
- Service-A application retrieving Bitcoin prices every minute and calculating 10-minute averages

The entire cluster can be deployed repeatedly from scratch using Terraform + GitHub Actions.

## Pipeline Stages (GitHub Actions)

1. **Checkout repository**
2. **Azure Login**
3. **ACR Login**
4. **Set AKS context - kube.config**
5. **Create Secrets**
6. **Deploy Services & Deployments**
7. **Install ingress-nginx LoadBalancer Controller**

## Manual Execution Instructions

1. When you running the project for the first time, you must provision the Azure AKS cluster using Terraform.
   Move into the `/infra` directory and run on cmd:

   - `az login`
   - `terraform apply`

   Once deployment completes, update your GitHub repository secrets (clientId, clientSecret, etc.),
   to allow the CI/CD workflow to authenticate properly.

2. Navigate to GitHub → Actions, select the workflow: “Build & Deploy to AKS” and trigger it manually using Run workflow.

3. After deployment, get the LoadBalancer external IP of the Ingress Controller:
   `kubectl get svc -n ingress-nginx`
   Look for the ingress-nginx-controller service under the EXTERNAL-IP column.

4. Open your browser and navigate to:
   `<external-ip>/service-a`
   `<external-ip>/service-b`
   If everything is configured correctly, you should receive valid responses from the pods through the Ingress Controller.

5. To check recent Bitcoin API fetches:
   `kubectl logs deploy/<Your-Service>`
   You will see each 1-minute update and 10-minute average, including timestamps.

6. To check Networkpolicy run:
   `kubectl exec -it deploy/service-a -- curl -v http://service-b`
   The request should fail, Service-A cannot communicate with Service-B, as enforced by the NetworkPolicy.

## Visual Output

Below is an example of the running system, where the users are fetched from MongoDB and the SHA tag is displayed via the Express consumer service:

![mongo-data](https://raw.githubusercontent.com/yakirovadya/mongo-data/refs/heads/main/images/run.png)

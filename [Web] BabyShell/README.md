# BabyShell

Topic Description:

**Author:** CHW

**Difficulty:** Easy

**Category:** Web
 
---
## Introduction
BabyShell is a Capture The Flag (CTF) challenge designed to test your skills in exploiting a simple web shell technique. The challenge involves leveraging the getTime() function to retrieve the current time, which is crucial for solving the puzzle.

## Installation
To deploy BabyShell using Docker Build, follow these steps:
### Clone the repository:
```
git clone https://github.com/Chw41/Individual-CTF-Topic.git
cd BabyShell
```  
### Using docker build to deploy the application
```
docker build -t babyshell .
docker run -d -p 80:80 babyshell
```

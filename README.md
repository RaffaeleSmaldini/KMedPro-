# KMedPro-
Advanced 3D segmentation for prostate tumor detection using KMedROI, KMeans, and Otsu on multiparametric MRI scans. Achieves high accuracy with advanced preprocessing, clustering, and evaluation using Dice &amp; IoU. Enhancing prostate cancer diagnosis and treatment planning. 🚀
---

# **KMedPro-: Advanced Prostate Tumor 3D Segmentation with Hybrid KMedROI & Clustering**

🚀 **Enhancing prostate cancer detection using advanced segmentation techniques!**  

## **📌 Overview**  
kMedPro- is an advanced **3D segmentation pipeline** for **prostate tumor detection** using **multiparametric MRI scans**. This project integrates **KMedROI**, **KMeans clustering**, and **Otsu thresholding** to enhance accuracy over traditional segmentation methods like **Otsu and Watershed**.  

✅ **Key Features:**  
- Hybrid **KMedROI + Clustering** for improved tumor detection  
- Advanced **preprocessing pipeline**: PCA, filtering, and morphological operations  
- **Evaluation using Dice & IoU metrics**  
- **Clinical relevance**: Assisting targeted biopsies & treatment planning  

---

## **📂 Dataset**  
The dataset consists of **48 prostate mpMRI studies** (T2-weighted & ADC sequences) from **Radboud University Medical Center**. Challenges in segmentation include:  
- **High variability** in prostate morphology  
- **Close proximity** of peripheral and transition zones  
- **Heterogeneous tumor appearances**, especially in the transition zone  

---

## **🛠️ Methodology**  
### **🔹 Traditional Approaches**  
1. **Otsu Thresholding**: Histogram-based method for foreground-background separation  
2. **Watershed Segmentation**: Region-based technique treating images as topographic surfaces  

### **🔹 Proposed Hybrid Model**  
1. **KMedROI (K-Median Region of Interest)**:  
   - **Eliminates irrelevant structures** to focus on the tumor  
   - **Refines ROI** for improved segmentation  
2. **KMedROI + KMeans**:  
   - Clusters tumor regions with **higher precision**  
3. **KMedROI + Otsu**:  
   - Combines thresholding with ROI segmentation  

---

## **⚙️ Pipeline Implementation**
### **1️⃣ Preprocessing**  
- **Normalization** (Min-Max Scaling)  
- **Filtering** (Gaussian, Anisotropic, Homomorphic)  
- **Dimensionality Reduction** (PCA)  
- **Transformations** (Logarithmic, Sharpening)  

### **2️⃣ Segmentation Techniques**  
- **Otsu’s Thresholding**  
- **Watershed Segmentation**  
- **KMeans Clustering**  
- **Hybrid KMedROI Segmentation**  

### **3️⃣ Post-processing**  
- **Morphological operations** (filling gaps, removing noise)  
- **Active Contour Refinement**  

---

## **📊 Evaluation Metrics**  
1. **Intersection over Union (IoU)**:  
   Measures overlap between the predicted and ground truth segmentation.  

2. **Dice Similarity Coefficient (DSC)**:  
   Measures segmentation accuracy.  

---

## **📈 Results**
| Model                | IoU (Dense Slice) | Avg IoU | Dice (Dense Slice) | Avg Dice |
|----------------------|-----------------|--------|-------------------|--------|
| Otsu                | 0.2750          | 0.4774 | 0.4148            | 0.4678 |
| Watershed           | 0.3526          | 0.6935 | 0.5048            | 0.6726 |
| **KMedROI + KMeans** | **0.5125**      | **0.7169** | **0.6573**      | **0.6964** |
| KMedROI + Otsu      | 0.4113          | 0.5954 | 0.5699            | 0.5814 |

🚀 **Findings:**  
- **KMedROI + KMeans achieves the highest accuracy**  
- **Otsu struggles** with complex prostate structures  
- **Watershed is noise-sensitive** but effective  
- **KMedROI significantly improves segmentation by focusing on tumor regions**  

---

## **📥 Installation**
### **🔧 Requirements**
- **MATLAB (Recommended)**
- **Python (Optional for visualization)**
- **Required Libraries**:
  - Image Processing Toolbox
  - Statistics and Machine Learning Toolbox

### **💻 Setup**
1.
```bash
git clone https://github.com/YourUsername/ProSegNet.git
```
2. Open MATLAB Online and set the project directory.
3. Download the dataset from [Medical Segmentation Decathlon Dataset](https://drive.google.com/drive/folders/1HqEgzS8BV2c7xYNrZdEAnrHk7osJJ--2). (If you want to reproduce the experiment, download the Prostate Dataset)
4. Unzip the dataset
5. Place the dataset folder in "DATA". (Rename 'Prostate' if you want to reproduce the experiment)
---

## **🚀 Usage**
| Run any "*NAME*_main.m" file to train and test 
| Run any  "*NAME*_test.m" file, in PipelineTesting, to observe step for step pipeline.

---

## **🔮 Future Developments**
- **Integrate Deep Learning models** for better segmentation  
- **Expand dataset validation** for improved generalization  
- **Optimize real-time segmentation** for clinical applications  

---

## **👨‍🔬 Authors**
- **Dr. Smaldini Raffaele**  
- **Dr. Ardillo Michele**  
- **Supervisor: Prof. Andrea Guerriero**  

---
## **📚 References**
1. [Medical Segmentation Decathlon Dataset](https://drive.google.com/drive/folders/1HqEgzS8BV2c7xYNrZdEAnrHk7osJJ--2)
2. [Isolation of Prostate Gland in T1-Weighted Magnetic Resonance Images using Computer Vision](https://ieeexplore.ieee.org/document/)
3. [Detection of tumours from MRI scans using Segmentation techniques](https://ieeexplore.ieee.org/document/9532867)
4. [Segmentation of rectum from CT images using K-means clustering for the EBRT of prostate cancer](https://ieeexplore.ieee.org/document/7955181)
---

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
1. **KMedROI (K-Means density-based slice wise Region of Interest)**:  
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
#### Given the mode of the supported project, each pipeline was found empirically through experiments; 
#### We propose a more complex approach via grid search to choose the order of the "blocks" (transformation and filters), followed by a further grid search for their parameters. 
---

## **📊 Evaluation Metrics**  
1. **Intersection over Union (IoU)**:  
   Measures overlap between the predicted and ground truth segmentation.  

2. **Dice Similarity Coefficient (DSC)**:  
   Measures segmentation accuracy.  

---

## **📈 Test Results with Heuristic**
| Model                | IoU (Dense Slice) | Avg IoU | Dice (Dense Slice) | Avg Dice |
|----------------------|-----------------|--------|-------------------|--------|
| Otsu                | 0.2750          | 0.4774 | 0.4148            | 0.4678 |
| Watershed           | 0.3526          | 0.6935 | 0.5048            | 0.6726 |
| **KMedROI + KMeans** | **0.5125**      | **0.7169** | **0.6573**      | **0.6964** |
| KMedROI + Otsu      | 0.4113          | 0.5954 | 0.5699            | 0.5814 |

### *MEDICAL CHALLENGE RESULTS*
![Table 8 Medical Decathlon Results](https://github.com/RaffaeleSmaldini/kMedPro-/blob/main/AboutProstate/MedicalChallenge_table8.png)

🚀 **Findings:**  
- **KMedROI + KMeans achieves the highest accuracy**  
- **Otsu struggles** with complex prostate structures  
- **Watershed is noise-sensitive** but effective  
- **KMedROI significantly improves segmentation by focusing on tumor regions**
### *Densest slice segmentation Subject 2*
![Segmentation Densest Slice Only](https://github.com/RaffaeleSmaldini/kMedPro-/blob/main/SegmentationSUB2.png)
*run our algorithm to observe the 3D DSC results*
---

## **📥 Installation**
### **🔧 Requirements**
- **MATLAB (Recommended)**
- **Python (we plan to re-write the whole project in python)**
- **Required Libraries**:
  - Image Processing Toolbox
  - Statistics and Machine Learning Toolbox

### **💻 Setup**
1.
```bash
git clone https://github.com/RaffaeleSmaldini/kMedPro-.git
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
2. [Isolation of Prostate Gland in T1-Weighted Magnetic Resonance Images using Computer Vision](https://ieeexplore.ieee.org/document/9070912)
3. [Detection of tumours from MRI scans using Segmentation techniques](https://ieeexplore.ieee.org/document/9532867)
4. [Segmentation of rectum from CT images using K-means clustering for the EBRT of prostate cancer](https://ieeexplore.ieee.org/document/7955181)
5. [Nature Article](https://www.nature.com/articles/s41467-022-30695-9#Sec2)
6. [All challenges results](https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-022-30695-9/MediaObjects/41467_2022_30695_MOESM1_ESM.pdf)
7. [Medical Decathlon general link](http://medicaldecathlon.com/)
---

## Citing Our Work :+1: 

If you use our work or code in your research, please cite our repository:

1. [RaffaeleSmaldini/kMedPro-](https://github.com/RaffaeleSmaldini/kMedPro-)
2. [github.com/MicheleArdillo](https://github.com/MicheleAdillo)

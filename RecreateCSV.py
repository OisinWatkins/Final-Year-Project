from PIL import Image
import numpy as np
from collections import Counter
import matplotlib.pyplot as plt

def threshold(imageArray):
    balanceArr = []
    newArr = imageArray.copy()
    for eachRow in imageArray:
        for eachPix in eachRow:
            avgNum = np.mean(eachPix[:3])
            balanceArr.append(avgNum)

    balance = np.mean(balanceArr) - 17

    for Row in newArr:
        for Pix in Row:
            if np.mean(Pix[:2]) > balance:
                Pix[0] = 255
                Pix[1] = 255
                Pix[2] = 255
                #Pix[3] = 255
            else:
                Pix[0] = 0
                Pix[1] = 0
                Pix[2] = 0
                #Pix[3] = 255
    return newArr

FilePath_Image = 'D:\\FYP Experiment Data\\1 Tap Moving Average\\Resolution 0-1\\Bob Strunz\\Bob Strunz_20190201152725.jpg'
i0 = Image.open(FilePath_Image)
iar0 = np.asarray(i0)

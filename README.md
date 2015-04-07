# [vfx 2015 Spring](http://www.csie.ntu.edu.tw/~cyy/courses/vfx/15spring/ "Digital Visual Effects 2011 Spring") @ CSIE.NTU.EDU.TW
## project #1: High Dynamic Range Imaging ([original link](http://www.csie.ntu.edu.tw/~cyy/courses/vfx/11spring/assignments/))

## Algorithm

### #1: Alignment (Medain Threshold Bitmap)
  將圖片RGB資訊轉成灰階，方便後續採取Median Threshold Bitmap方法對位，為了增加對位的精準以及處理速度，把原圖尺寸一直縮小二分之一
到最後有七張不同尺寸等級的圖片，以論文裡的演算法對每兩張不同曝光時間的照片互相比較，並將每次位移暫存並移動，其餘部分填上黑色，從最小尺寸等級一直到原尺寸，完成alignment對位．

1. 直接利用matlab指令將圖片RGB資訊轉成灰階
2. 原圖尺寸一直縮小二分之一，到最後每張不同曝光時間的照片一共分別有七張不同尺寸
3. 計算所有圖片的中位數，圖片裡的像素若大於中位數計為1，否則為0．第二種方法為找出所有像素在中位數±4範圍內，並記為0，其餘記為1．
4. 使用上述兩種方法對每兩張不同曝光時間的圖片進行八個不同方位的比較，算出一個最佳位置
5. 從尺寸最小的圖片往上做比較，進行對位


### #2: HDR 
1.我們參考Paul E. Debevec 論文中所提到的演算法，最小化目標方程式
![](https://cloud.githubusercontent.com/assets/11753996/7004184/d38f9a00-dc99-11e4-9e53-b0a3354c7874.png)


2.滿足矩陣Ax=b，以SVD求解矩陣x，得到g函數，帶入權重值及曝光時間lnΔt
![](https://cloud.githubusercontent.com/assets/11753996/7004201/12c4cec0-dc9a-11e4-926c-625f89f4e6f9.png)


3.計算多張不同曝光時間同像素的點，找出其算術平均值得到HDR圖像


### #3: Tone Mapping (global operater)
1.Tone Mapping目的為將HDR轉為LDR，假設 
####Lw=0.27R+0.67G+0.06B

2.先在圖像中取得每一點的亮度值並取log，取得平均值再做exponetional
![](https://cloud.githubusercontent.com/assets/11753996/7006655/7dddc6a6-dcb5-11e4-87e2-d35b361f983c.png)


3.定義normal-key a值為0.18，並代入平均亮度Lw至下列方程式求得Lm
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7006675/97173850-dcb5-11e4-898a-5190125ffb3d.png">
</div>

4.設定場景中最大亮度為1.5，求得Ld
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7006744/1c087e20-dcb6-11e4-9e8f-5d42b487120f.png">
</div>

5.最後重新計算LDR每個channel的亮度值
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7006781/6a431866-dcb6-11e4-911a-852b4feccaaa.png">
</div>

##Result

### #1: Alignment (Medain Threshold Bitmap)

### #2: HDR 
input:
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7029336/82208048-dd8f-11e4-84d4-18cde0eb320d.JPG">
</div>


### Method #4: Tone Mapping (local operater)
1.找出一定範圍內，使得所有像素亮度都差不多，沒有任何的sharp contrast，之後分析這些相片convolve


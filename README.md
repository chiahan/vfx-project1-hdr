# [vfx 2015 Spring](http://www.csie.ntu.edu.tw/~cyy/courses/vfx/15spring/ "Digital Visual Effects 2011 Spring") @ CSIE.NTU.EDU.TW
## project #1: High Dynamic Range Imaging ([original link](http://www.csie.ntu.edu.tw/~cyy/courses/vfx/11spring/assignments/))

## 程式執行方式
使用matlab2014撰寫，執行program資料夾中的main.m，參數都在main.m中最上方修改，output會有hdr和tone mapping後的結果在program資料夾中
```
%   folder: the (relative) path containing the image set.
%   type_: 'global' or 'local' tone mapping
%   phi: used by local tone mapping
%   epsilon: used by local tone mapping (find the max gaussian scale)
%   lambda: smoothness factor for gsolve.
%   prefix: output LDR file's prefix name
%   [srow scol]: the dimension of the resized image for sampling in gsolve.
%   shift_bits: the maximum number of bits in the final offsets in
%   alignment.
%
function main(folder, type_, alpha_, delta_, white_, phi, epsilon, lambda, prefix, srow, scol, shift_bits)
```

## 實作內容
1. alignment
2. hdr
3. tonemapping(global operator)
4. tonemapping(local operator)

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
<img src="https://cloud.githubusercontent.com/assets/11753996/7006744/1c087e20-dcb6-11e4-9e8f-5d42b487120f.png")
</div>

5.最後重新計算LDR每個channel的亮度值

<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7006781/6a431866-dcb6-11e4-911a-852b4feccaaa.png">
</div>




### #4: Tone Mapping (local operater)
1.找出一定範圍內，使得所有像素亮度都差不多，沒有任何的sharp contrast，對亮度分佈Lm與Gaussian profile做摺積（convolution)轉換，
並拿兩張Gaussian blurred images相減，由於要找出V1與V2在相近區域內有相同的亮度梯度（luminance gradient)，給予一個threshold ε，流程如下

<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7024702/41896464-dd71-11e4-920a-3a0169c586af.png")
</div>

2.求得Ld，最後重新計算LDR每個channel的亮度值

<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7024715/592569ce-dd71-11e4-9878-5e3219d1058a.png")
</div>

##Result
 
### #1: Alignment (Medain Threshold Bitmap)
由於原圖之間差異太小，看不出來效果
我們故意拿一張圖位移很多來測試
input:
圖一
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7038017/f52f47f6-dddd-11e4-82d6-fe619562621a.jpg">
</div>
圖一位移後
![test2](https://cloud.githubusercontent.com/assets/11717755/7038036/34aeb92a-ddde-11e4-962c-30bf6e5821e2.jpg)
output:

設定在7層（最大位移2^7)時會移回來
 
另外，照片之間差異小時，層數設太大反而會因為照片曝光差太多而失敗，通常設定3層可以得到較好的比較結果
### #2: HDR 
input:
f4 2"
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7028775/b675c3d0-dd8a-11e4-8bf8-95d054e6b4df.JPG">
</div>
f4 1"
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7029017/c0e9a56e-dd8c-11e4-94df-4d60324268ce.JPG">
</div>
f4 0.5"
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7029081/323783c6-dd8d-11e4-8365-8d90f6cf16a7.JPG">
</div>
f4 1/5
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7029109/7219b464-dd8d-11e4-89e9-83148e517470.JPG">
</div>
f4 1/8
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7029210/87ecc1ae-dd8e-11e4-8c6f-2e69a0c0bff9.JPG">
</div>
f4 1/15
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7029336/82208048-dd8f-11e4-84d4-18cde0eb320d.JPG">
</div>
f4 1/30
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7029336/82208048-dd8f-11e4-84d4-18cde0eb320d.JPG">
</div>
output:
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7030912/a0951ec0-dd9a-11e4-96b5-61a238cdab0b.png">
 
### #3: Tone Mapping (global operater)
input:用hdr演算法得到的output(同上圖）
output:
a越大圖月亮，white越大圖越亮（亮部細節增加,暗部細節減少）
 
 
### #4: Tone Mapping (local operater)
input:用hdr演算法得到的output(同上上圖）
output:
a = 0.5, phi = 8, epsilon = 0.05
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7030453/5c67bbe8-dd97-11e4-96c1-be31bc9e4fd0.png">
</div>
 
比較：matlab tone mapping function得到的結果（下圖）
<div style="display:block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7031044/6c03f14e-dd9b-11e4-89fb-df3066e1ed96.png">
</div>


i = imread('ucid00002.tif');
e1 = im2double(rgb2gray(i));
t = dctmtx(8);
b = blockproc(e1,[8 8], @(block_struct) (t * block_struct.data * t') .* repmat(100,8,8));
c = blockproc(e1,[8 8], @(block_struct) t * block_struct.data * t');
quant = [16  11  10  16  24   40   51   61
        12  12  14  19  26   58   60   55
        14  13  16  24  40   57   69   56
        14  17  22  29  51   87   80   62
        18  22  37  56  68   109  103  77
        24  35  55  64  81   104  113  92
        49  64  78  87  103  121  120  101
        72  92  95  98  112  100  103  99];
quantizedimg= blockproc(b, [8 8], @(block_struct) round(block_struct.data ./ quant) .*quant);
mask = [1 1 1 1 0 0 0 0
        1 1 1 0 0 0 0 0
        1 1 0 0 0 0 0 0
        1 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0];
b2 = blockproc(quantizedimg,[8 8],@(block_struct) mask .* block_struct.data);
e2 = blockproc(b2,[8 8], @(block_struct) (t' * block_struct.data * t) ./ repmat(100,8,8));
ee = blockproc(b2,[8 8], @(block_struct) (t' * block_struct.data * t));
%histvalue = blockproc(c,[8 8], @(block_struct) block_struct.data(1,2));
%[x, y] = hist(reshape(histvalue,1,prod(size(histvalue))), 300);
%plot(y,x)
decval=blockproc(ee,[8 8], @(block_struct) round(10 * block_struct.data(1,2)) / 10);
sn= blockproc(ee,[8 8], @(block_struct) block_struct.data(1,2) ./ abs(block_struct.data(1,2)));
d= sn .* (decval - round(decval));
[a,b]= hist(reshape(d,1,numel(d)));
%plot(d)
plot(b,a)
J = imnoise(e2,'gaussian',0,0.01);
%figure, imshow(J);
c1 = blockproc(J,[8 8], @(block_struct) t * block_struct.data * t');
c11= blockproc(c1, [8 8], @(block_struct) block_struct.data(1,2));
c12= reshape(c11, 1, numel(c11));
    l =  blockproc(b2,[8 8], @(block_struct) block_struct.data(1,2));
    m = abs(l);
n = sum(sum(m));
o = 2 * nnz(l) * 14 + 4 * n;
r = 2 * nnz(l) * 14 - 4 * n;
n0 = prod(size(l)) - nnz(l);
s = (n0)^2 * 14^2;
u = sqrt(s - (r * o));
v = log((-(n0) * 14 + u) / (2 * prod(size(l)) * 14 + 4 * n));
lam = (-2 / 14) * v;
c0=1-exp((-lam*14)/2);
cl=1/(lam) * (1- exp(-lam*14));
ll=reshape(m,1, prod(size(l)));
k=1;
w=[];

for x = ll
    if x == 0
        if -7 <= c12(1,k) < 7
            zz=1/(c0) * exp(-lam*c12(1,k));
            w=[w zz];
        else
            w=[w 0];
        end
    elseif x ~= 0
        if -7 <= c12(1,k) < 7
            x1= x / abs(x);
            zz = 1/(cl) * exp(-x1 * lam * (c12(1,k) + 7));
            w=[w zz];
        else
            w=[w 0];
        end
    end
    k=k+1;
end
w=reshape(w,64,48);


Q=medfilt2(J);
R=imnoise(J, 'gaussian',0,0.01);
S=Q+R;
H=1/9.* [1 1 1;1 1 1;1 1 1];
one=1;
H_filt= filter(one, [one -1], H);
convoluted_image=conv2(S, H_filt);
convoluted_image([514 513],:)=[];
convoluted_image(:,[385 386])=[];
f=S-convoluted_image;
f1= hist(f) / max(max(hist(f)));
K=medfilt2(convoluted_image);
imshow(K);

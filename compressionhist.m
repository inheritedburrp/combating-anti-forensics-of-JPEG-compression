e = imread('ucid00002.tif');
e1 = rgb2gray(e);
e1 = im2double(e1);
t = dctmtx(8);
dct = @(block_struct) t * block_struct.data * t';
b = blockproc(e1,[8 8],dct);
mask = [1 1 1 1 0 0 0 0
1 1 1 0 0 0 0 0
1 1 0 0 0 0 0 0
1 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0];
b2 = blockproc(b,[8 8],@(block_struct) mask .* block_struct.data);
invdct = @(block_struct) t' * block_struct.data * t;
e2 = blockproc(b2,[8 8],invdct);
u=dct2(e1);
v=dct2(e2);
edges=[-10 -2:0.25:2 10];
hist(u,edges);

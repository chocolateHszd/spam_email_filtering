clc
clear all
addpath helpers
load data/data4b.mat
	% load training and test data: X, y, Xtest, ytest

	% recover number of classes
k = max([y;ytest]) - min([y;ytest]) + 1;

	% construct indicator matrices of labels Y,Ytest from class vectors y,ytest
[t,n] = size(X);
Y = zeros(t,k);
Y(t*y + (1:t)') = ones(t,1);
[te,n] = size(Xtest);
Ytest = zeros(te,k);
Ytest(te*ytest + (1:te)') = ones(te,1);

	% plot data if you want to see what's going on
	% train indicated by '.', test indicated by 'o', colors show classes
figure
traintestind = [ [ones(t,1) zeros(t,1)]; [zeros(te,1) ones(te,1)] ];
pltdig([X; Xtest],[Y; Ytest],traintestind,3);

%%%%%%%%%% prelim %%%%%%%%%%

	% will compare 4 different versions of each algorithm (ls, pca, kmeans):
	% 1. standard
	% 2. kernelized (polynomial kernel)
	% 3. kernelized (gaussian kernel) 
	% 4. normalized (gaussian kernel)
	% so 12 different learning algorithms in total (3 supervised, 6 unsup)

	% kernels
K2 = polykernel(X,X,2);
K3 = gausskernel(X,X,6);
K4 = gausskernel(X,X,6);
K2test = polykernel(Xtest,Xtest,2);
K3test = gausskernel(Xtest,Xtest,6);
K4test = gausskernel(Xtest,Xtest,6);

beta1 = 5;
beta2 = 50;
beta3 = 20;
beta4 = 20;

Reps = 100;	% number random restarts for kmeans

	% need to store training objective values
objs = zeros(1,4);	% supervised ls
objp = zeros(1,4);	% unsupervised pca
objk = zeros(Reps,4);	% unsupervised kmeans, for each restart
minobjk = Inf + zeros(1,4);	% minimum kmeans objective

	% need to store training misclassification errors
errs = zeros(1,4);	% supervised ls
errp = zeros(1,4);	% unsupervised pca
errk = zeros(1,4);	% unsupervised kmeans

	% need to store test misclassification errors
errse = zeros(1,4);	% supervised ls
errpe = zeros(1,4);	% unsupervised pca
errke = zeros(1,4);	% unsupervised kmeans

%%%%%%%%%% run experiment %%%%%%%%%%

%%%%% supervised ls %%%%%
[U1s,W1s,objs(1)] = lsq(X,Y,beta1);
[A2s,B2s,objs(2)] = lsq_kernel(K2,Y,beta2);
[A3s,B3s,objs(3)] = lsq_kernel(K3,Y,beta3);
[A4s,B4s,objs(4)] = lsq_normalized(K4,Y,beta4);
		% train misclass errors
C1s = classify(X,W1s);
errs(1) = misclasserr(Y,C1s);
C2s = classify_kernel(K2,A2s);
errs(2) = misclasserr(Y,C2s);
C3s = classify_kernel(K3,A3s);
errs(3) = misclasserr(Y,C3s);
C4s = classify_normalized(K4,A4s);
errs(4) = misclasserr(Y,C4s);
		% test misclass errors
C1se = classify(Xtest,W1s);
errse(1) = misclasserr(Ytest,C1se);
C2se = classify_kernel(K2test,A2s);
errse(2) = misclasserr(Ytest,C2se);
C3se = classify_kernel(K3test,A3s);
errse(3) = misclasserr(Ytest,C3se);
C4se = classify_normalized(K4test,A4s);
errse(4) = misclasserr(Ytest,C4se);

%%%%% unsupervised pca %%%%%
[Y1p,U1p,W1p,objp(1)] = pca(X,k,beta1);
[Y2p,B2p,A2p,objp(2)] = pca_kernel(K2,k,beta2);
[Y3p,B3p,A3p,objp(3)] = pca_kernel(K3,k,beta3);
[Y4p,B4p,A4p,objp(4)] = pca_normalized(K4,k,beta4);
		% train misclass errors
C1p = classify(X,W1p);
errp(1) = minalignerr(Y,C1p);
C2p = classify_kernel(K2,A2p);
errp(2) = minalignerr(Y,C2p);
C3p = classify_kernel(K3,A3p);
errp(3) = minalignerr(Y,C3p);
C4p = classify_normalized(K4,A4p);
errp(4) = minalignerr(Y,C4p);
		% test misclass errors
C1pe = classify(Xtest,W1p);
errpe(1) = minalignerr(Ytest,C1pe);
C2pe = classify_kernel(K2test,A2p);
errpe(2) = minalignerr(Ytest,C2pe);
C3pe = classify_kernel(K3test,A3p);
errpe(3) = minalignerr(Ytest,C3pe);
C4pe = classify_normalized(K4test,A4p);
errpe(4) = minalignerr(Ytest,C4pe);

%%%%% unsupervised kmeans %%%%%
for r = 1:Reps
	
	[C1,U1,W1,objk(r,1)] = kmeans(X,k,beta1);
	if objk(r,1) < minobjk(1)	% keep best
		minobjk(1) = objk(r,1); 
		C1k = C1;
		W1k = W1;
	end
	
	[C2,B2,A2,objk(r,2)] = kmeans_kernel(K2,k,beta2);
	if objk(r,2) < minobjk(2)	% keep best
		minobjk(2) = objk(r,2); 
		C2k = C2;
		A2k = A2;
	end
	
	[C3,B3,A3,objk(r,3)] = kmeans_kernel(K3,k,beta3);
	if objk(r,3) < minobjk(3)	% keep best
		minobjk(3) = objk(r,3); 
		C3k = C3;
		A3k = A3;
	end

	[C4,B4,A4,objk(r,4)] = kmeans_normalized(K4,k,beta4);
	if objk(r,4) < minobjk(4)	% keep best
		minobjk(4) = objk(r,4); 
		C4k = C4;
		A4k = A4;
	end
	
objk(r,:)	% you can turn this off if the output annoys you
	
end
		% train misclass errors
errk(1) = minalignerr(C1k,Y);
errk(2) = minalignerr(C2k,Y);
errk(3) = minalignerr(C3k,Y);
errk(4) = minalignerr(C4k,Y);
		% test misclass errors
C1ke = classify(Xtest,W1k);
errke(1) = minalignerr(Ytest,C1ke);
C2ke = classify_kernel(K2test,A2k);
errke(2) = minalignerr(Ytest,C2ke);
C3ke = classify_kernel(K3test,A3k);
errke(3) = minalignerr(Ytest,C3ke);
C4ke = classify_normalized(K4test,A4k);
errke(4) = minalignerr(Ytest,C4ke);

%%%%%%%%%% report results %%%%%%%%%%

minobjk(1,4)=minobjk(1,4)*t;
objp(1,4)=objk(1,4)*t;
objs(1,4)=objk(1,4)*t;


	% report train objective values
%objk	% all kmeans objectives
meanobjk = mean(objk,1)	% mean objective for kmeans
minobjk	% min objective for kmeans
objp	% pca
objs	% ls

	% report train misclass errs
errk	% kmeans
errp	% pca
errs	% ls

	% report test misclass errs
errke	% kmeans
errpe	% pca
errse	% ls

	% plot training embeddings and clusterings
% figure
% pltdig(Y1p,Y,C1k,2);
% figure
% pltdig(Y2p,Y,C2k,2);
% figure
% pltdig(Y3p,Y,C3k,2);
% figure
% pltdig(Y4p,Y,C4k,2);

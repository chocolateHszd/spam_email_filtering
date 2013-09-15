function [ Y,B,A,obj ] = kmeans_kernel(K,k,beta)
[t,n]=size(K);
current_Y=zeros(t,k);
for i=1 :t
current_Y(i,randi(k,1,1))=1;
end

Last_Y=current_Y;
check=0;
    while check==0
        B=(current_Y.'*current_Y)\(current_Y.');
        D= 0.5*diag(K)*ones(k,1).'+0.5*ones(t,1)*diag(B*K*B.').'-K*B.';
        for i=1:t
            [a,j]=min(D(i,:));
            temp=zeros(1,k);
            temp(1,j)=1;
            current_Y(i,:)=temp;
        end
        if current_Y==Last_Y
            check=1;
        else
           Last_Y=current_Y;
        end
    end
    Y=current_Y;
 % K' or K ??
A=(K+beta*eye(t))\(B.'*(Y.'*Y));
obj=0.5*trace((eye(t)-Y*B)*K*(eye(t)-Y*B).');

end


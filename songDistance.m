function [ distance ] = songDistance(mu1,mu2,cov1,cov2)

    %take the inverse
    iCov1 = inv(cov1);  %pinv
    iCov2 = inv(cov2);

    KL = 0.5 * (trace(cov1*iCov2) + trace(cov2*iCov1) + trace((iCov1+iCov2)*(mu1-mu2)*transpose(mu1-mu2)));
    gamma = 100;
    distance = 1-exp(-gamma/KL);

end


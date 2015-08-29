% John Canty                                           Created: 08/28/15
% Yildiz Lab

% Generates a Bivariate Gaussian Function

function F = D2GaussianRot(x,xdata)
 % parameters = [Amp,x0,y0,sigma_x,sigma_y,Covxx,Covxy,Covyy,angle(radians)
 % Cov Matrix = [a b;b c]
 a = cos(x(9))^2/(2*x(4)^2) + sin(x(9))^2/(2*x(5)^2);
 b = -sin(2*x(9))/(4*x(4)^2) + sin(2*x(9))/(4*x(5)^2);
 c = sin(x(9))^2/(2*x(4)^2) + cos(x(9))^2/(2*x(5)^2);
 
 % Bivariate Gaussian function
 F = x(1)*exp(-(x(6)*(xdata(:,:,1)-x(2)).^2+2*x(7)*(xdata(:,:,1)-x(2)).*(xdata(:,:,2)-x(3))+x(8)*(xdata(:,:,2)-x(3)).^2));
 
  
 

 % F = z*exp(-((cos(f)^2/(2*g^2) + sin(f)^2/(2*h^2))*(x-d).^2+2*(-sin(2*f)/(4*g^2) + sin(2*f)/(4*h^2))*(x-d).*(y-e)+(sin(f)^2/(2*g^2) + cos(f)^2/(2*h^2))*(y-e).^2));
function [ Angle, AngleDegrees ] = MeasureAngleLines( Ax1, Ay1, Ax2, Ay2, Bx1, By1, Bx2,By2)
%Measure an angle theta between two vectors A and B, each defined by 2 points with
%coordinates x1,y1 and x2,y2
%Angle is in radians, AngleDegrees is in degrees

% get components and length of 2 vectors
Ax=Ax2-Ax1;
Bx=Bx2-Bx1;
Ay=Ay2-Ay1;
By=By2-By1;

ALength=sqrt( Ax^2 + Ay^2 );
BLength=sqrt( Bx^2 + By^2 );

%get sign of cos(theta) from scalar product of two vectors
cosTheta=(Ax*Bx + Ay*By)/( ALength*BLength );

%get sinTheta from vectorial product of two vectors
sinTheta=(Ax*By - Ay*Bx)/( ALength*BLength );

%calcualte angle
if cosTheta >= 0
    Theta=asin(sinTheta);
elseif cosTheta < 0
    Theta=pi - asin(sinTheta);
end

%convert angle to positive angle
if Theta < 0
    Angle=2*pi + Theta;
else
    Angle=Theta;
end
    
AngleDegrees=Angle*57.29578; %conversion to degrees


end


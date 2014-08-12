% This function generates the rotation matrix with the order of
% yaw,pitch and roll
function R = rotation(alpha, beta, gama)
    yaw = [cos(alpha) -sin(alpha) 0;
           sin(alpha) cos(alpha) 0;
           0 0 1];  % Rotation matrix about z axis
    pitch = [cos(beta) 0 sin(beta);
             0 1 0;
             -sin(beta) 0 cos(beta)];   % Rotation matrix about y axis
    roll = [1 0 0;
            0 cos(gama) -sin(gama);
            0 sin(gama) cos(gama)]; % Rotation matrix about x axis
    R = yaw*pitch*roll;
    
end
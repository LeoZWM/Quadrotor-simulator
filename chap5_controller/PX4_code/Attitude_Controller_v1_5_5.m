function [rates_sp]=Attitude_Controller_v1_5_5(att_sp,cur_state,yaw_sp_move_rate, para)
% ���룺 att_sp Ŀ����̬��Ԫ��;  cur_state  ��ǰ��̬��Ԫ��
% ����� rats_sp Ŀ����ٶȣ�3 X 1��

R_sp = q2dcm(att_sp);  % ��Ŀ����̬ת�ɾ�����ʽ
R = q2dcm(cur_state);

R_z = R(:, 3);
R_sp_z = R_sp(:, 3);

R_tran = R';
e_R = R_tran * (cross(R_z, R_sp_z));
e_R_z_sin = norm(e_R);  % |e_R| = sin(R_z,R_sp_z)
e_R_z_cos = R_z' * R_sp_z; % R_z �� R_sp_z ���ǵ�λ����

% yaw_w = R_sp(3,3) * R(3,3);  % yaw ���Ƶ�Ȩ��  z��н�Խ��Ȩ�ؾ�ԽС��yaw���Ƶ���Ҫ��Խ��
                         % ��ζ����ע�� pitch-roll �Ŀ��ƣ���֮������Ϊ z��
                         % �Ѿ������ˣ�Ҫ��ʼ�� yaw ���п�����
yaw_w = R_tran * R_sp_z;
yaw_w = yaw_w(3,1) * yaw_w(3,1);

% R_rp=zeros(3,3);

if e_R_z_sin > 0
    e_R_z_angle = atan2(e_R_z_sin, e_R_z_cos);
    e_R_z_axis = e_R / e_R_z_sin;
    
    e_R = e_R_z_axis * e_R_z_angle;
    
    e_R_cp = zeros(3,3);
    e_R_cp(1,2) = -e_R_z_axis(3);
    e_R_cp(1,3) = e_R_z_axis(2);
    e_R_cp(2,1) = e_R_z_axis(3);
    e_R_cp(2,3) = -e_R_z_axis(1);
    e_R_cp(3,1) = -e_R_z_axis(2);
    e_R_cp(3,2) = e_R_z_axis(1);
    
    R_rp = R * ...
        (eye(3) + e_R_cp * e_R_z_sin + e_R_cp * e_R_cp * (1 - e_R_z_cos));
    
else
    R_rp = R;
end

R_sp_x = R_sp(:,1);
R_rp_x = R_rp(:,1);
e_R(3) = atan2(cross(R_rp_x, R_sp_x)' * R_sp_z, R_rp_x' * R_sp_x) * yaw_w;

if e_R_z_cos < 0
    q_error = dcm2q(R_tran * R_sp);
    if q_error(1) >= 0
        e_R_d = q_error(2:4, 1) * 2;
    else
        e_R_d = q_error(2:4, 1) * -2;
    end
    
    direct_w = e_R_z_cos * e_R_z_cos * yaw_w;
    e_R = e_R * (1 - direct_w) + e_R_d * direct_w;
end

rates_sp = para.att_p .* e_R;

for i=1:3
    rates_sp(i) = ...
        constrain(rates_sp(i), -para.ratesMax(i), para.ratesMax(i));
end

rates_sp(3) = rates_sp(3) + yaw_sp_move_rate * yaw_w * para.yaw_ff;

end

function value = constrain(val, min_val, max_val)

if val > max_val
    value = max_val;
elseif val < min_val
    value = min_val;
else
    value = val;
end

end
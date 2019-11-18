function [att_control] = ...
    Attitude_Rates_Controller(rates_sp, rates_curr, t, para)
% ���룺 rates_sp Ŀ����ٶȣ�rates_curr ��ǰ���ٶȣ� 
%        rates_prev ��һʱ�̵Ľ��ٶȣ� dt ����
% ����� att_control ��̬������

persistent rates_prev
persistent rates_int
if t==0
    rates_prev = rates_curr;
    rates_int = zeros(3,1);
end

error = rates_sp - rates_curr;

att_control = para.rate_p .* error + ...   % P
    para.rate_d .* (rates_prev - rates_curr) / para.Ts + ...% D
    para.rate_i .* rates_int + ... % I
    para.rate_ff .* rates_sp;   

rates_prev = rates_curr;
rates_int = rates_int + error * para.Ts;

end
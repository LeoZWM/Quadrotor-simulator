function [vel_sp] = Position_Controller(pos_sp, pos_curr, para)
% ���룺 pos_sp Ŀ��λ�ã�pos_curr ��ǰλ��
% ����� vel_sp Ŀ���ٶ�

pos_err = pos_sp - pos_curr;
vel_sp = pos_err .* para.pos_p;
end
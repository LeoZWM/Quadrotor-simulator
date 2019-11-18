clear
clc

timeSpan=40;  % ����ʱ��
dt=0.1;       % ����

time=0:dt:timeSpan;

% att_sp=euler2q(0,0,0);  % Ŀ����̬��Ԫ�� 
pos_sp=[1;0;0];            % Ŀ��λ��(NED)
yaw_des=0;                 % Ŀ��ƫ����
euler_ini=[0;0;0];         % ��ʼ��̬ roll pitch yaw
rates_ini=[0;0;0];         % ��ʼ���ٶ�
pos_ini=[0;0;0];           % ��ʼλ��
vel_ini=[0;0;0];           % ��ʼ�ٶ�
thrust=0.5;                % ������ 0~1

euler_log=zeros(3,size(time,2)+1); % ��¼ÿһʱ�̵���̬��
euler_log(:,1)=euler_ini;
rates_log=zeros(3,size(time,2)+1); % ��¼ÿһʱ�̵Ľ��ٶȣ�������ϵ�£�
rates_log(:,1)=rates_ini;
pos_log=zeros(3,size(time,2)+1);   % ��¼ÿһʱ�̵�λ��
pos_log(:,1)=pos_ini;
vel_log=zeros(3,size(time,2)+1);   % ��¼ÿһʱ�̵��ٶ�
vel_log(:,1)=vel_ini;
att_sp_log=zeros(4,size(time,2)+1); % ��¼ÿһʱ�̵�Ŀ����̬
vel_sp_log=zeros(3,size(time,2)+1); % ��¼ÿһʱ�̵�Ŀ���ٶ�
rates_sp_log=zeros(3,size(time,2)+1); % ��¼ÿһʱ�̵�Ŀ����ٶ�
att_control_log=zeros(4,size(time,2)+1); % ��¼ÿһʱ�̵���̬������
thrust_int_log=zeros(3,size(time,2)+1); % ��¼ thrust �Ļ���ֵ

for i=1:size(time,2)
    % λ���ڻ�
    vel_sp=Position_Controller(pos_sp,pos_log(:,i));
    vel_sp_log(:,i+1)=vel_sp;
    
    % λ���⻷
    q_cur=euler2q(euler_log(1,i),euler_log(2,i),euler_log(3,i));
    [~,att_sp,thrust_int_,att_sp_thrust]=Velocity_Controller(vel_sp,vel_log(:,i),dt,thrust_int_log(:,i),q_cur,yaw_des);
    thrust_int_log(:,i+1)=thrust_int_;
    att_sp_log(:,i+1)=att_sp;
    
%     att_sp=euler2q(0,pi/12,0);
    % ��̬�ڻ�
    rates_sp=Attitude_Controller(att_sp,q_cur,0);
    rates_sp_log(:,i+1)=rates_sp;
    % ��̬�⻷
    if i==1
        rates_prev=rates_ini;
    else
       rates_prev=rates_log(:,i-1); 
    end
    att_control=Attitude_Rates_Controller(rates_sp,rates_log(:,i),rates_prev,dt);
%     att_control(4)=att_sp_thrust;
    att_control(4)=thrust;
    att_control_log(:,i+1)=att_control;
    
    % �õ�ÿ�������ת��
    motor_speed=Mixer(att_control);
    % �õ��������������ϵ���������
    [F,M]=MotorModel(motor_speed);
    % ����λ�ú���̬
    y0=[pos_log(:,i);vel_log(:,i);euler_log(:,i);rates_log(:,i)];
    [t,y]=ode45(@(t,y) DynamicModel(t,y,F,M),[0 dt],y0);
    
    pos_log(1:2,i+1)=y(end,1:2)';
    pos_log(3,i+1)=0;
    vel_log(:,i+1)=y(end,4:6)';
    euler_log(:,i+1)=y(end,7:9)';
    rates_log(:,i+1)=y(end,10:12)';
   
end

% ��ͼ
axis_x=(1:size(time,2)+1)*dt;
figure(1)
% ��̬��
subplot(2,2,1)
plot(axis_x,euler_log(1,:),axis_x,euler_log(2,:),axis_x,euler_log(3,:));
legend('roll/rad','pitch/rad','yaw/rad');
title('��̬');
% λ�ã�NED��
subplot(2,2,2)
plot(axis_x,pos_log(1,:),axis_x,pos_log(2,:),axis_x,pos_log(3,:),axis_x,zeros(1,size(axis_x,2))+1);
legend('x','y','z','Ŀ��');
title('λ��');
% Ŀ����̬
euler=zeros(3,i+1);
for j=1:i+1
   euler(:,j)=q2euler(att_sp_log(:,j));
end
subplot(2,2,3)
plot(axis_x,euler(1,:),axis_x,euler(2,:),axis_x,euler(3,:));
title('Ŀ����̬');
legend('roll','pitch','yaw');
subplot(2,2,4)
plot(axis_x,vel_sp_log(1,:),axis_x,vel_sp_log(2,:),axis_x,vel_sp_log(3,:));
legend('x','y','z');
title('Ŀ���ٶ�');

figure(2)
subplot(2,2,1)
plot(axis_x,vel_log(1,:),axis_x,vel_log(2,:),axis_x,vel_log(3,:));
legend('x','y','z');
title('�ٶ�');
subplot(2,2,3)
plot(axis_x,vel_sp_log(1,:),axis_x,vel_sp_log(2,:),axis_x,vel_sp_log(3,:));
legend('x','y','z');
title('Ŀ���ٶ�');
subplot(2,2,2)
plot(axis_x,rates_log(1,:),axis_x,rates_log(2,:),axis_x,rates_log(3,:));
legend('x','y','z');
title('���ٶ�');
subplot(2,2,4)
plot(axis_x,rates_sp_log(1,:),axis_x,rates_sp_log(2,:),axis_x,rates_sp_log(3,:));
legend('x','y','z');
title('Ŀ����ٶ�');

% figure(3)
% plot(axis_x,att_control_log(1,:),axis_x,att_control_log(2,:),axis_x,att_control_log(3,:),axis_x,att_control_log(4,:));
% legend('roll','pitch','yaw','thrust');
% title('��̬������');

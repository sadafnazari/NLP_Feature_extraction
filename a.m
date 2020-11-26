%------------First we should read our audio file.--------------%
%[Y, FS] = audioread('f.wav');
[Y, FS] = audioread('a.wav');
figure;
plot(Y);
title('The signal');
%------------After choosing a suitable length for our frame
%------------we are supposed to to the frame blocking process on it!-----------%
Frame_size = 400;
Overlap = 240;
Shift_frame = Frame_size - Overlap;
Num_of_frames = floor((length(Y) - Overlap)/Shift_frame);
Blocked_Frames = zeros(Frame_size, Num_of_frames);
for i=1: Num_of_frames
    Start_index = (i-1)*Shift_frame+1;
    Blocked_Frames(:, i) = Y(Start_index:(Start_index+Frame_size-1));
end
figure;
plot(Blocked_Frames(:,120));
title('Frame number 120');
%-----------Then we can put our window on each frame------%
%-----------Our window is Rectangular----------------%
Rectangular_window = rectwin(Frame_size);
After_Rectangular = zeros(Frame_size, Num_of_frames);
for i=1: Num_of_frames
   for j=1: Frame_size
       After_Rectangular(j,i) = Blocked_Frames(j,i) * Rectangular_window(j);
   end
end
figure;
plot(After_Rectangular(:,120));
title('Frame 120 After Rectangular windowing');
%-----------Then we should do preemphasize on our signal-------------%
%-----------Because we were not told to do this, we commented them-----%
After_PE_r = zeros(Frame_size, Num_of_frames);
for i=1: Num_of_frames
    for j=2: Frame_size
        After_PE_r(j,i) = After_Rectangular(j,i) - 0.96* After_Rectangular(j-1,i);
    end
end
figure;
plot(After_PE_r(:, 120));
title('Frame 120 After Preemphasize(With Rectangular window)');
%-----------Then we should remove DC offset from our signal----------%
After_remove_DC_r = zeros(Frame_size, Num_of_frames);
for i=1: Num_of_frames
    After_remove_DC_r(:,i) = After_Rectangular(:,i) - mean(After_Rectangular(:,i));
end
figure;
plot(After_remove_DC_r(:,120));
title('Frame 120 after remove DC offset(With Rectangular window)');
%-----------Here we can calculate Energy of each frame---------------%
Energy_r = zeros(1, Num_of_frames);
for i=1: Num_of_frames
    for j=1: Frame_size
        Energy_r(i) = Energy_r(i) + After_PE_r(j,i) * After_PE_r(j,i);
    Energy_r(i) = Energy_r(i) / Frame_size;
    end
end
figure;
plot(Energy_r());
title('Energy of signal(With Rectangular window)');
%-----------Here we can calculate ZCR--------------%
ZCR_r = zeros(1, Num_of_frames);
for i=1: Num_of_frames
    ZCR_r(i) = mean(abs(diff(sign(After_PE_r(:,i)))));
end
figure;
plot(ZCR_r);
title('The zero crossing rate of signal(With Rectangular window)');
%------------------------------------------------------------------------%
%----------Our window is Hamming------------------%
Hamming_window = zeros(1, Frame_size);
for i=1: Frame_size
    Hamming_window(i) = 0.54 - (0.46*cos((2*3.14*i)/Frame_size));
end
After_Hamming = zeros(Frame_size, Num_of_frames);
for i=1: Num_of_frames
   for j=1: Frame_size
       After_Hamming(j,i) = Blocked_Frames(j,i) * Hamming_window(j);
   end
end
figure;
plot(After_Hamming(:,120));
title('Frame 120 After Hamming windowing');
%-----------Then we should do preemphasize on our signal-------------%
After_PE_h = zeros(Frame_size, Num_of_frames);
for i=1: Num_of_frames
    for j=2: Frame_size
        After_PE_h(j,i) = After_Hamming(j,i) - 0.96* After_Hamming(j-1,i);
    end
end
figure;
plot(After_PE_h(:,120));
title('Frame 120 After Preemphasize(With Hamming window)');
%-----------Then we should remove DC offset from our signal----------%
After_remove_DC_h = zeros(Frame_size, Num_of_frames);
for i=1: Num_of_frames
    After_remove_DC_h(:,i) = After_PE_h(:,i) - mean(After_PE_h(:,i));
end
figure;
plot(After_remove_DC_h(:,120));
title('Frame 120 after remove DC offset(With Hamming window)');
%-----------Here we can calculate Energy of each frame---------------%
Energy_h = zeros(1, Num_of_frames);
for i=1: Num_of_frames
    for j=1: Frame_size
        Energy_h(i) = Energy_h(i) + After_remove_DC_h(j,i) * After_remove_DC_h(j,i);
    Energy_h(i) = Energy_h(i) / Frame_size;
    end
end
figure;
plot(Energy_h());
title('Energy of signal(With Hamming window)');
%-----------Here we can calculate ZCR--------------%
ZCR_h = zeros(1, Num_of_frames);
for i=1: Num_of_frames
    ZCR_h(i) = mean(abs(diff(sign(After_remove_DC_h(:,i)))));
end
figure;
plot(ZCR_h);
title('The zero crossing rate of signal(With Hamming window)');
%-----------Now we want to determine the pitch frequency----------%
%-----------We do that with autocorrelation approach--------------%
%-----------We only do that for a.wav-----------------------------%
%-----------First we should remove silence parts------------------%
index_of_loud = Energy_h > 0.000000002;
Y_without_silence_blocked = Blocked_Frames(:,index_of_loud);
[temp, size_of_loud] = size(Y_without_silence_blocked);

Ipos = zeros(1, size_of_loud);
Fpitch = zeros(1, size_of_loud);
for i=1: size_of_loud
    [peaks, locs] = findpeaks(autocorr(Y_without_silence_blocked(:, i), Frame_size -1));
    Ipos(i) = locs(peaks == max(peaks));
    Fpitch(i) = FS / Ipos(i);
end
figure;
plot(Fpitch);
title('Pitch frequency of our speech');









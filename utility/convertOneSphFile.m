function outFiles = convertOneSphFile(sphFile, phnDir, outputWavDir, channel)
global params; %AREF
[~, name, ~] = fileparts(sphFile);
 [wav, fs] = readSphAsWav(sphFile);
outFiles = cell(0, 1);
if (size(wav, 2) == 1)
 %AREF
%      outWav=[];
%      [m,n]=size(wav);
%         VAD=my_vad(wav,8000,'a');
%        for i=1:m
%           if VAD(i,1)~=0
%            outWav=cat(1,outWav,wav(i,1));
%           end
%        end
 %END AREF
      phn = [phnDir name '.phn'];
       if (~exist(phn, 'file'))
           % create phn file.
          ssvad(sphFile, phn);
       end
       outWav = removeSilenceUsingPhn(wav, phn);
% outWav=wav;
    if (length(outWav) > fs / 2)
        wavwrite(outWav, fs, 16, [outputWavDir name '.wav']);
        outFiles{1, 1} = [outputWavDir name '.wav'];
    else
        outFiles{1, 1} = 0;
    end
else
    if (nargin < 3)
        channel = 'AB';
    end
   
    if (~isempty(strfind(channel, 'A')))
        phnDir = params.nist08PhnDirA; %AREF
        % Process channel A
         phn_A = [phnDir name '.phn']; % ghable .phn alamate '_A' bud ke hazf kardAM
        if (~exist(phn_A, 'file'))
             % create phn file.
             ssvad(sphFile, phn_A, 'A');
         end
         outWav_A = removeSilenceUsingPhn(wav(:, 1), phn_A);
        
         %AREF
%       outWav_A=[];
%        AA=wav(:,1);
%       [m,n]=size(AA);
%          VAD=my_vad(AA,8000,'a');
%         for ii=1:m
%            if VAD(ii,1)~=0
%             outWav_A=cat(1,outWav_A,AA(ii,1));
%            end
%         end
%         outWav_A=wav(:,1);
 %END AREF
        if (length(outWav_A) > fs / 2)
            wavwrite(outWav_A, fs, 16, [outputWavDir name '_A.wav']);
            outFiles{1, 1} = [outputWavDir name '_A.wav'];
        else
            outFiles{1, 1} = 0;
        end
    end
    if (~isempty(strfind(channel, 'B')))
        phnDir = params.nist08PhnDirB; %AREF
         % Process channel 2
         phn_B = [phnDir name '.phn'];
         if (~exist(phn_B, 'file'))
             % create phn file.
             ssvad(sphFile, phn_B, 'B');
         end
         outWav_B = removeSilenceUsingPhn(wav(:, 2), phn_B);

  %AREF
%       outWav_B=[];
%        BB=wav(:,2);
%       [m,n]=size(BB);
%          VAD=my_vad(BB,8000,'a');
%         for ii=1:m
%            if VAD(ii,1)~=0
%             outWav_B=cat(1,outWav_B,BB(ii,1));
%            end
%         end
%         outWav_B=wav(:,2);
 %END AREF
        wavwrite(outWav_B, fs, 16, [outputWavDir name '_B.wav']);
        if (length(outWav_B) > fs / 2)
            if (isempty(outFiles))
                outFiles{1, 1} = [outputWavDir name '_B.wav'];
            else
                outFiles{2, 1} = [outputWavDir name '_B.wav'];
            end
        else
            if (isempty(outFiles))
                outFiles{1, 1} = 0;
            else
                outFiles{2, 1} = 0;
            end
        end
    end
end
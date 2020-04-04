function Y = vsm(filename, method, start, duration, outfile)
    close all;
    % parameters
    NF = 10;
    % display parameters
    showpeaks = true;

    if ~exist(filename, 'file')
        error('Error. \n%s file doesn''t exist', filename);
    end
    if isempty(start) || (start < 14)
        start = 14;
    end

    Fs = 8000;
    A = csvread(filename);
    if (size(A,2) < 2) || (size(A,1) < Fs)
        error('Error. \n%s is an invalid csv file', filename);
    end
    if isempty(duration)
        duration = floor(size(A,1)/Fs) - start - 4;
    end
    
    Y = zeros(duration,3);
    Yidx = 1;

    I = A(:,1);
    Q = A(:,2);
    if method == 1 
        X = atan2(Q,I); % 4-Quadrant version
        % Fix jump in phase
        delta = [0;diff(X)];
        L = zeros(size(X));
        L(delta < -pi) = 1;
        L(delta > pi) = -1;
        csum = 0;
        for n = 1:length(X)
            if L(n) ~= 0
                csum = csum + L(n);
            end
            L(n) = csum;
        end
        X = X + 2*pi*L;
    else
        X = abs((I - mean(I))+1i*(Q - mean(Q)));
    end

    Fd = 50;
    Xd = decimation(X,Fs/Fd);

    if (method == 3)
        bpFilt = designfilt('bandpassfir', 'StopbandFrequency1', 10, 'PassbandFrequency1', 15, ...
                            'PassbandFrequency2', 25, 'StopbandFrequency2', 30, 'StopbandAttenuation1', 60, ...
                            'PassbandRipple', 1, 'StopbandAttenuation2', 60, 'SampleRate', Fd);
        Xd = filtfilt(bpFilt,Xd);
        Xd = Xd.^2;
    end

    % PSD
    Fr = 0.1; % Frequency Resolution
    T = 1/Fr;
    Nd = Fd * T;

    % Reference
    R = 1./mean(reshape(A(:,4), Fs, []));
    Rbpm = mean(reshape(A(:,3), Fs, []));

    hFig = figure(1);
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
    hFig.Color = 'white';
    hFig.InvertHardcopy = 'off';

    % initial value
    self = struct('bBR',false,'bHR',false,'swcount',0,'rpm',0,'bpm',0,'brList',[],'hrList',[]);
    nodeobj = struct('freq',0,'weight',0,'taint',true);

    pxx = zeros(5, Nd/2+1);
    k = 0;
    while (k < duration)
        fprintf(1,'-------------------------- %d\n', k);
        % PSD
        sidx = (start + k - T)*Fd;
        ri = 1;
        for ni = -4:2:4
            nidx = sidx+ni*Fd;
            [pxx(ri,:),f] = periodogram(Xd(nidx+1:nidx+Nd),hanning(Nd),Nd,Fd);
            ri = ri + 1;
        end
        sde = 10*log10(mean(pxx));
        % Peaks
        [brpeaks, hrpeaks] = peakdetect(sde, f);

        searchbr();
        searchhr();
        
        detecthr();

        plot(f,sde);
        hold on;   
        if showpeaks
            plotpeaks(brpeaks, self.bBR, 'g');
            plotpeaks(hrpeaks, self.bHR, 'r');
        end

        xlabel('Frequency (Hz)');
        ylabel('Magnitude (dB)');
        title(sprintf('Power Spectral Density (%.1fs, %.1fHz, %dHz) - %d second',T,Fr,Fd,start+k));

        yl = ylim;
        % BPM
        if self.bpm ~= 0
            hr = self.bpm/60;
            if self.bHR
                plot([hr; hr]', yl,'c--');
                Y(Yidx,3) = self.bpm;
            else
                plot([hr; hr]', yl,'c:');
            end
            text(hr, yl(2)-5, sprintf('\\leftarrow BPM: %d', floor(self.bpm)));
        end
        
        % Reference        
        Y(Yidx,1) = start + k;
        hr = mean(R(start+k-T:start+k));
        plot([hr; hr]', yl,'m--');
        text(hr, yl(2)-10, sprintf('\\leftarrow Ref BPM (R-R): %d', floor(hr*60)));
        Y(Yidx,2) = floor(hr*60);
        fprintf(1,'Ref Freq (R-R): %.2f\n', hr);
        hr = mean(Rbpm(start+k-T:start+k))/60;
        plot([hr; hr]', yl,'k:');
        text(hr, yl(2)-15, sprintf('\\leftarrow Ref BPM: %d', floor(hr*60)));
        %fprintf(1,'Ref Freq: %.2f\n', hr);

        hold off;
        xlim([0.2 15]);
        hFrame = getframe(hFig);
        [im, map] = rgb2ind(hFrame.cdata, 256, 'nodither');
        if k == 0
            imwrite(im, map, outfile, 'gif', 'DelayTime', 1, 'LoopCount', Inf);
        else
            imwrite(im, map, outfile, 'gif', 'DelayTime', 1, 'WriteMode', 'append');
        end

        Yidx = Yidx + 1;
        if self.bHR && (self.swcount == 0)
            k = k + T/2;
        else
            k = k + 1;  % search every second
        end
    end % while (k)
    
    Y(Yidx:end,:) = [];

    function searchbr
    end

    function searchhr
        if self.bHR
            self.hrList{1}.weight = self.hrList{1}.weight - 0.5;
            weight = 0;
            fsum = 0; fcount = 0;
            for pidx = 1:length(hrpeaks)
                L = round(hrpeaks(pidx).freq/self.hrList{1}.freq);
                if L > NF
                    break;
                end
                if abs(hrpeaks(pidx).freq - L*self.hrList{1}.freq) < 0.15                    
                    if hrpeaks(pidx).strong
                        if (L == 1)
                            fsum = hrpeaks(pidx).freq;
                            weight = detectharmonics(fsum);
                            fcount = 1;
                            break;
                        end
                        weight = weight + 0.5;
                        fsum = fsum + 2*hrpeaks(pidx).freq/L; fcount = fcount + 2;
                    else
                        weight = weight + 0.25;
                        fsum = fsum + hrpeaks(pidx).freq/L; fcount = fcount + 1;
                    end
                    hrpeaks(pidx).valid = false;
                end
            end
            % search other fundamental peaks
            mw = 0; mf = 0;
            for pidx = 1:length(hrpeaks)
                if hrpeaks(pidx).freq > 2.0
                    break;
                end
                if hrpeaks(pidx).valid
                    w = detectharmonics(hrpeaks(pidx).freq);
                    if (w > mw)
                        mw = w; mf = hrpeaks(pidx).freq;
                    end
                end
            end

            fprintf(1, '%.2f -> %.2f  %.2f -> %.2f\n', weight, mw, fsum/fcount, mf);  
            if mw > (weight+0.5)
                self.swcount = self.swcount + 1;
                if self.swcount > 3
                    self.hrList{1}.freq = mf;
                    self.hrList{1}.weight = mw;
                    fprintf(1,'---> Freq: %.2f (%.2f)\n', mf, mw);
                    self.swcount = 0;
                end
            elseif fcount ~= 0
                self.swcount = 0;
                self.hrList{1}.freq = fsum/fcount;
                self.hrList{1}.weight = weight;
                fprintf(1,'Freq: %.2f (%.2f)\n', fsum/fcount, weight);
            end
        else
            for pidx = 1:length(hrpeaks)
                if hrpeaks(pidx).valid
                    if hrpeaks(pidx).freq > 2.0
                        break;
                    end
                    % search in existing list
                    bFound = false;
                    for lidx = 1:length(self.hrList)
                        if any(abs(hrpeaks(pidx).freq - (1:NF)*self.hrList{lidx}.freq) < 0.15)
                            self.hrList{lidx}.freq = hrpeaks(pidx).freq;
                            self.hrList{lidx}.taint = true;
                            self.hrList{lidx}.weight = detectharmonics(self.hrList{lidx}.freq);
                            bFound = true;
                            break;
                        end
                    end

                    if ~bFound
                        nodeobj.freq = hrpeaks(pidx).freq;
                        nodeobj.weight = detectharmonics(nodeobj.freq);
                        self.hrList{length(self.hrList)+1} = nodeobj;
                    end
                end
            end % for

            % Adjust weight
            for lidx = 1:length(self.hrList)
                if ~self.hrList{lidx}.taint
                    self.hrList{lidx}.weight = self.hrList{lidx}.weight - 0.5;
                else
                    self.hrList{lidx}.taint = false;
                end
            end
        end
        
        function w = detectharmonics(freq)
            w = 0;
            for idx = pidx:length(hrpeaks)
                if hrpeaks(idx).valid 
                    if any(abs(hrpeaks(idx).freq - (1:NF)*freq) < 0.15)
                        hrpeaks(idx).valid = false;
                        if hrpeaks(idx).strong
                            w = w + 0.5;
                        else
                            w = w + 0.25;
                        end
                    end
                end
            end
        end
    end

    function plotpeaks(peaks, bEn, mc)
        if ~isempty(peaks)
            for n = 1:length(peaks)
                if peaks(n).strong
                    mt = [mc '*'];
                else
                    mt = [mc '+'];
                end
                if ~bEn && peaks(n).valid
                    ms = 2;
                else
                    ms = 5;
                end
                plot(peaks(n).freq, peaks(n).value, mt, 'MarkerSize', ms);
            end
        end
    end

    function detecthr
        if self.bHR
            if self.hrList{1}.weight >= 1.0
                self.bpm = self.hrList{1}.freq*60;
                if self.hrList{1}.weight > 2.0
                    self.hrList{1}.weight = 2.0;
                end
            else
                self.bHR = false;
            end
        else
            if ~isempty(self.hrList)
                w = 0;
                L = length(self.hrList);
                for n = 1:L
                    if self.hrList{n}.weight > w
                        w = self.hrList{n}.weight;
                        idx = n;
                    end
                end

                if self.hrList{idx}.weight > 2.0
                    self.bHR = true;
                    self.bpm = self.hrList{idx}.freq*60;
                    self.hrList{idx}.weight = 2.0;
                    if L > 1
                        self.hrList{1} = self.hrList{idx};
                        self.hrList(2:L) = [];
                    end
                end
            end
        end
    end

end

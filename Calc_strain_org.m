%% Calc_strain Day 6 + 12
% Calculates strains for a full length recording based on the DIC results 
% and domain file
clear;
clc;
close all;

cd Z:\projects1\Crone-Projects\Harshal-Kanade\Org_Project\'Full CMCF Data'\KPA_CM\KPA10\'DIC Results'
datanames = dir;

cd Z:\projects1\Crone-Projects\Harshal-Kanade\Org_Project\'Full CMCF Data'\KPA_CM\KPA10\'Domain Files'
domainnames = dir;

for i = 1: length(datanames)
    if i == 1 || i ==2
        continue
    end
    pix_size = 0.65; % 0.65 for 10x images
    dataname = datanames(i).name;
    domainname = domainnames(i).name;
  
    cd Z:\projects1\Crone-Projects\Harshal-Kanade\Org_Project\'Full CMCF Data'\KPA_CM\KPA10\'DIC Results'
    load(dataname);
    cd Z:\projects1\Crone-Projects\Harshal-Kanade\Org_Project\'Full CMCF Data'\KPA_CM\KPA10\'Domain Files'
    load(domainname);

    cd Z:\projects1\Crone-Projects\Harshal-Kanade\FIDIC
    domain = domain/max(domain(:)); % scale so max value is 1
    domain = 1-domain;
    domain2D = median(domain,3); % Take median over time. This is fine for cardiomyocites, because they don't migrate
    domain2D = logical(domain2D); % convert to logical
    % Downsample domain
    % x and y grid points don't start at 1,1. First crop off edges so that
    % domain matches start and end points of x and y.
    domain2D = domain2D( min(y(:)):max(y(:)), min(x(:)):max(x(:)) );
    domain2D = downsample(domain2D,d0); % downsample number of rows
    domain2D = downsample(domain2D',d0)'; % downsample number of cols
    domain2D = ~domain2D;
    
    % Convert from pixels to microns
    x=x*pix_size;
    y=y*pix_size;
    u=u*pix_size;
    v=v*pix_size;
    
    num_images = size(u,3);
    
    for k = 1:num_images 
        
        % --- Get displacements ---
        
        % Get k-th displacements
       u_k = u(:,:,k);
       v_k = v(:,:,k);
       
       cd Z:\projects1\Crone-Projects\Harshal-Kanade\FIDIC\
       % Remove outliers using gradient threshold
       threshold = 5;
       [uf,vf] = gradient_filter(u_k,v_k,threshold);
        
        % --- Get strains ---
        
        % Filter displacements. This is optional. It will reduce spatial
        % resolution slightly, but it will also reduce noise.
        u_k2 = smooth2a(uf,1); % The 1 gives a 3x3 mean smoothing
        v_k2 = smooth2a(vf,1);
        
        % Displacement gradients
        [dudx, dudy] = grad2do5( u_k2/(d0*pix_size) );
        [dvdx, dvdy] = grad2do5( v_k2/(d0*pix_size) ); 
        
        % --- Strain Calculations ---
        % Compute directly by using elementary mech of mater equations
        exx = dudx;
        eyy = dvdy;
        exy = 1/2*(dudy + dvdx);
        
        % --- Principal strains ---
        e1 = (exx+eyy)/2 + sqrt( ((exx+eyy)/2).^2 + exy.^2 );
        e2 = (exx+eyy)/2 - sqrt( ((exx+eyy)/2).^2 + exy.^2 );
        
        u_plot=uf;  u_plot(~domain2D)=nan;
        v_plot=vf;  v_plot(~domain2D)=nan;
        e1_plot=e1;  e1_plot(~domain2D)=nan;
        e2_plot=e2;  e2_plot(domain2D)=nan;
        Exx_plot=exx;  Exx_plot(~domain2D)=nan;
        Eyy_plot=eyy;  Eyy_plot(~domain2D)=nan;
        Exy_plot=exy;  Exy_plot(~domain2D)=nan;
        
        E1(:,:,k) = e1_plot; E2(:,:,k) = e2_plot;
        EXX(:,:,k) = Exx_plot; EYY(:,:,k) = Eyy_plot; EXY(:,:,k) = Exy_plot;
    end
    
    % This should leave you with 3D arrays of strains (Exx, Eyy, Exy, Prin. E1
    % and Prin. E2) that you can use.
    
    % Each cell is the strain value for that location at that time point
    % Dimensions are 106 (x coords) x 84 (y coords) x Unknown (# of frames in
    % video)
    %%
    cd Z:\projects1\Crone-Projects\Harshal-Kanade\Org_Project\'Full CMCF Data'\KPA_CM\KPA10
    %Saving file
    %find which data we are looking at
    start = strfind(dataname,"10kPa");
    pathname = fileparts('Strain_Data\');
    filename = extractBetween(dataname,start,start+14) + "_data.mat";
 
    matfile = fullfile(pathname, filename);
    save(matfile, "E2", "-v7")
    
end



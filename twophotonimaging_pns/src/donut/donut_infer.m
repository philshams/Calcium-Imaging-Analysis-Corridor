function [elem, Im] = donut_infer(orig_Im, model, Nextract)

% make sure that optimized functions are available
mexALL;

% retrieve parameters from model
W        = model.W         ;
tErr     = model.tErr      ;
Bias     = model.Bias      ;
Nmaps    = model.Nmaps     ;
isfirst  = model.isfirst   ;
pos      = model.pos       ;
subs     = model.subs      ;
dimSS    = model.dimSS     ;
NSS      = model.NSS       ;
KS       = model.KS        ;
PrVar    = model.PrVar     ;
Nmax     = model.Nmax      ;
sig1     = model.sig1      ;
sig2     = model.sig2      ;

% user inputs
if exist('Nextract', 'var') && Nextract > 0
    Nmax = model.KS * Nextract;
    tErr = 0;
end

Im = double(orig_Im);
if ~(isempty(sig1) || isempty(sig2))
    Im = normal_img(Im, sig1, sig2);
end

lx = size(W,1);
L = size(Im,1);
Params = [Nmax tErr PrVar L lx Nmaps];

WtW = zeros(2*lx-1, 2*lx-1, Nmaps, Nmaps);
for i = 1:Nmaps
    W0 = W(:,:,i);
    for j = 1:Nmaps
        WtW(:,:,j,i) = filter2(W(:,:,j), W0, 'full');
    end
end

A = squeeze(WtW(lx, lx, :, :));
Akki = zeros(size(A));
for i =1:NSS
    Akki(subs{i}, subs{i}) = ...
        A(subs{i}, subs{i}) + 1/PrVar * eye(dimSS(i));
end
Akki = inv(Akki);

Wy = zeros(L, L, Nmaps);
for i = 1:Nmaps
    Wy(:,:,i) = filter2(W(:,:,i), Im, 'same');
end
Wy = reshape(Wy, L*L*Nmaps, 1);

H = extract_coefs2_SBC(Wy, WtW, Params, Im, W, Bias, Akki, isfirst, pos);
elem = get_elem(H, L, isfirst, KS);
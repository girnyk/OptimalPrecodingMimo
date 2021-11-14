function d = convertBinToDec(b, varargin)
%CONVERTBINTODEC Convert binary vectors to decimal numbers.
%   D = CONVERTBINTODEC(B) converts a binary vector B to a decimal value D. When B is
%   a matrix, the conversion is performed row-wise and the output D is a
%   column vector of decimal values. The default orientation of the binary
%   input is Right-MSB; the first element in B represents the least
%   significant bit.
%

% Typical error checking.
error(nargchk(1,3,nargin,'struct'));

% --- Placeholder for the signature string.
sigStr = '';
flag = '';
p = [];

% Check the type of the input B
if ~(isnumeric(b) || islogical(b))
    error(message('comm:convertBinToDec:InvalidInput1'));
end

inType = class(b);
b = double(b);  % To allow non-doubles to work

% --- Identify string and numeric arguments
for i=1:length(varargin)
   if(i>1)
      sigStr(size(sigStr,2)+1) = '/';
   end
   % --- Assign the string and numeric flags
   if(ischar(varargin{i}))
      sigStr(size(sigStr,2)+1) = 's';
   elseif(isnumeric(varargin{i}))
      sigStr(size(sigStr,2)+1) = 'n';
   else
      error(message('comm:convertBinToDec:InvalidInputArg'));
   end
end

% --- Identify parameter signitures and assign values to variables
switch sigStr
    
    % --- convertBinToDec(d)
    case ''
        
	% --- convertBinToDec(d, p)
	case 'n'
      p		= varargin{1};

	% --- convertBinToDec(d, flag)
	case 's'
      flag	= varargin{1};

	% --- convertBinToDec(d, p, flag)
	case 'n/s'
      p		= varargin{1};
      flag	= varargin{2};

	% --- convertBinToDec(d, flag, p)
	case 's/n'
      flag	= varargin{1};
      p		= varargin{2};

   % --- If the parameter list does not match one of these signatures.
   otherwise
      error(message('comm:convertBinToDec:InvalidSeqArg'));
end

if isempty(b)
   error(message('comm:convertBinToDec:InputEmpty'));
end

if max(max(b < 0)) || max(max(~isfinite(b))) || (~isreal(b)) || ...
     (max(max(floor(b) ~= b)))
    error(message('comm:convertBinToDec:InvalidInput2'));
end

% Set up the base to convert from.
if isempty(p)
    p = 2;
elseif max(size(p)) > 1
   error(message('comm:convertBinToDec:NonScalarBase'));
elseif (floor(p) ~= p) || (~isfinite(p)) || (~isreal(p))
   error(message('comm:convertBinToDec:InvalidBase'));
elseif p < 2
   error(message('comm:convertBinToDec:BaseLessThan2'));
end

if max(max(b)) > (p-1)
   error(message('comm:convertBinToDec:InvalidInputElement'));
end

n = size(b,2);

% If a flag is specified to flip the input such that the MSB is to the left.
if isempty(flag)
   flag = 'right-msb';
elseif ~(strcmp(flag, 'right-msb') || strcmp(flag, 'left-msb'))
   error(message('comm:convertBinToDec:InvalidFlag'));
end

if strcmp(flag, 'left-msb')

   b2 = b;
   b = b2(:,n:-1:1);

end

%%% The conversion
max_length = 1024;
pow2vector = p.^(0:1:(size(b,2)-1));
size_B = min(max_length,size(b,2));
d = b(:,1:size_B)*pow2vector(:,1:size_B).';

% handle the infs...
idx = find(max(b(:,max_length+1:size(b,2)).') == 1);
d(idx) = inf;

% data type conversion
if ~strcmp(inType, 'logical')
    d = feval(inType, d);
end

% [EOF]

function b = convertDecToBin(varargin)
%CONVERTDECTOBIN Convert decimal numbers to binary numbers.
%   B = CONVERTDECTOBIN(D) converts a nonnegative integer decimal vector D to a
%   binary matrix B. Each row of the binary matrix B corresponds to one
%   element of D. The default orientation of the binary output is
%   Right-MSB; the first element in B represents the lowest bit.

% Typical error checking.
error(nargchk(1,4,nargin,'struct'));

% --- Placeholder for the signature string.
sigStr = '';
msbFlag = '';
p = [];
n = [];

% --- Identify string and numeric arguments
for i=1:nargin
   if(i>1)
      sigStr(size(sigStr,2)+1) = '/';
   end;
   % --- Assign the string and numeric flags
   if(ischar(varargin{i}))
      sigStr(size(sigStr,2)+1) = 's';
   elseif(isnumeric(varargin{i}))
      sigStr(size(sigStr,2)+1) = 'n';
   else
      error(message('comm:convertDecToBin:InvalidArg'));
   end;
end;

% --- Identify parameter signitures and assign values to variables
switch sigStr
   % --- convertDecToBin(d)
   case 'n'
      d		= varargin{1};

	% --- convertDecToBin(d, n)
	case 'n/n'
      d		= varargin{1};
      n		= varargin{2};

	% --- convertDecToBin(d, msbFlag)
	case 'n/s'
      d		= varargin{1};
      msbFlag	= varargin{2};

	% --- convertDecToBin(d, n, msbFlag)
	case 'n/n/s'
      d		= varargin{1};
      n		= varargin{2};
      msbFlag	= varargin{3};

	% --- convertDecToBin(d, msbFlag, n)
	case 'n/s/n'
      d		= varargin{1};
      msbFlag	= varargin{2};
      n		= varargin{3};

	% --- convertDecToBin(d, n, p)
	case 'n/n/n'
      d		= varargin{1};
      n		= varargin{2};
      p  	= varargin{3};

	% --- convertDecToBin(d, n, p, msbFlag)
	case 'n/n/n/s'
      d		= varargin{1};
      n		= varargin{2};
      p  	= varargin{3};
      msbFlag	= varargin{4};

	% --- convertDecToBin(d, n, msbFlag, p)
	case 'n/n/s/n'
      d		= varargin{1};
      n		= varargin{2};
      msbFlag	= varargin{3};
      p  	= varargin{4};

	% --- convertDecToBin(d, msbFlag, n, p)
	case 'n/s/n/n'
      d		= varargin{1};
      msbFlag	= varargin{2};
      n		= varargin{3};
      p  	= varargin{4};

   % --- If the parameter list does not match one of these signatures.
   otherwise
      error(message('comm:convertDecToBin:InvalidArgSeq'));
end;

if isempty(d)
   error(message('comm:convertDecToBin:NoInput'));
end

inType = class(d);
d = double(d(:));
len_d = length(d);

if any(d(:) < 0) || any(~isfinite(d(:))) || ~isreal(d) || ~isequal(floor(d),d)
   error(message('comm:convertDecToBin:InvalidInput'));
end

% Assign the base to convert to.
if isempty(p)
    p = 2;
elseif max(size(p) ~= 1)
   error(message('comm:convertDecToBin:NonScalarBase'));
elseif (~isfinite(p)) || (~isreal(p)) || (floor(p) ~= p)
   error(message('comm:convertDecToBin:InvalidBase'));
elseif p < 2
   error(message('comm:convertDecToBin:BaseLessThan2'));
end;

% Determine minimum length required.
tmp = max(d);
if tmp ~= 0 				% Want base-p log of tmp.
   ntmp = floor( log(tmp) / log(p) ) + 1;
else 							% Since you can't take log(0).
   ntmp = 1;
end

% This takes care of any round off error that occurs for really big inputs.
if ~( (p^ntmp) > tmp )
   ntmp = ntmp + 1;
end

% Assign number of columns in output matrix.
if isempty(n)
   n = ntmp;
elseif max(size(n) ~= 1)
   error(message('comm:convertDecToBin:NonScalarN'));
elseif (~isfinite(n)) || (~isreal(n)) || (floor(n) ~= n)
   error(message('comm:convertDecToBin:InvalidN'));
elseif n < ntmp
   error(message('comm:convertDecToBin:SmallN'));
end

% Check if the string msbFlag is valid.
if isempty(msbFlag)
   msbFlag = 'right-msb';
elseif ~(strcmp(msbFlag, 'right-msb') || strcmp(msbFlag, 'left-msb'))
   error(message('comm:convertDecToBin:InvalidMsbFlag'));
end

% Initial value.
b = zeros(len_d, n);

% Perform conversion.
%Vectorized conversion for P=2 case
if(p==2)
    [~,e]=log2(max(d)); % How many digits do we need to represent the numbers?
    b=rem(floor(d*pow2(1-max(n,e):0)),p);
    if strcmp(msbFlag, 'right-msb')
        b = fliplr(b);
    end;
else
    for i = 1 : len_d                   % Cycle through each element of the input vector/matrix.
        j = 1;
        tmp = d(i);
        while (j <= n) && (tmp > 0)     % Cycle through each digit.
            b(i, j) = rem(tmp, p);      % Determine current digit.
            tmp = floor(tmp/p);
            j = j + 1;
        end;
    end;
    % If a msbFlag is specified to flip the output such that the MSB is to the left.
    if strcmp(msbFlag, 'left-msb')
        b2 = b;
        b = b2(:,n:-1:1);
    end;
end;

b = feval(inType, b);   % data type conversion

end
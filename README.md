# Deep-Learning Based Linear Precoding for MIMO Channels with Finite-Alphabet Signaling
This repository contains the codes for producing the figures from the following article: 

M. A. Girnyk (2021), "[Deep-Learning Based Linear Precoding for MIMO Channels with Finite-Alphabet Signaling](https://www.sciencedirect.com/science/article/abs/pii/S1874490721001397)," *Physical Communication*, vol. 48, 101402, Oct. 2021.

## Abstract
This paper studies the problem of linear precoding for multiple-input multiple-output (MIMO) communication channels employing finite-alphabet signaling. Existing solutions typically suffer from high computational complexity due to costly computations of the constellation-constrained mutual information. In contrast to existing works, this paper takes a different path of tackling the MIMO precoding problem. Namely, a data-driven approach, based on deep learning, is proposed. In the offline training phase, a deep neural network learns the optimal solution on a set of MIMO channel matrices. This allows the reduction of the computational complexity of the precoder optimization in the online inference phase. Numerical results demonstrate the efficiency of the proposed solution vis-à-vis existing precoding algorithms in terms of significantly reduced complexity and close-to-optimal performance.

## Preprint
A preprint of the article is available at https://arxiv.org/pdf/2111.03504.pdf.

## Software requirements
The codes have been developed in Matlab 2015a and should not require additional packages. 

## License
This code is licensed under the Apache-2.0 license. If you are using this code in any way for research that results in a publication, please cite the article above.

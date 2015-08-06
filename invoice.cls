%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Copyright (c) 2011 Trey Hunner                                          %
%                                                                          %
%  Permission is hereby granted, free of charge, to any person obtaining   %
%  a copy of this software and associated documentation files (the         %
%  "Software"), to deal in the Software without restriction, including     %
%  without limitation the rights to use, copy, modify, merge, publish,     %
%  distribute, sublicense, and/or sell copies of the Software, and to      %
%  permit persons to whom the Software is furnished to do so, subject to   %
%  the following conditions:                                               %
%                                                                          %
%  The above copyright notice and this permission notice shall be          %
%  included in all copies or substantial portions of the Software.         %
%                                                                          %
%  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,         %
%  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF      %
%  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                   %
%  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE  %
%  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION  %
%  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION   %
%  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.         %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\ProvidesClass{invoice}

\LoadClass[12pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[letterpaper,hmargin=0.79in,vmargin=0.79in]{geometry}
\usepackage[parfill]{parskip} % Do not indent paragraphs
\usepackage{fp} % Fixed-point arithmetic
\usepackage{calc} % Counters for totaling hours and cost
\usepackage{longtable}
\usepackage{fmtcount}
\usepackage{xstring} % Switch statement

\pagestyle{empty} % No page numbers
\linespread{1.5} % Line spacing

\setlength{\doublerulesep}{\arrayrulewidth} % Double rules look like one thick one

% Command for setting a default hourly rate
\newcommand{\feetype}[1]{
    \multicolumn{2}{l}{\textbf{#1}}
    \\
}

% Counters for totaling up hours and dollars
\newcounter{hours} \newcounter{subhours} \newcounter{cost} \newcounter{subcost}
\setcounter{hours}{0} \setcounter{subhours}{0} \setcounter{cost}{0} \setcounter{subcost}{0}

% Counter for row records
\newcounter{feeordernum}
\setcounter{feeordernum}{0}

% Formats inputed number with 2 digits after the decimal place
\newcommand*{\formatNumber}[1]{\FPround{\cost}{#1}{2}\cost} %

% Returns the total of counter
\newcommand*{\total}[1]{\FPdiv{\t}{\arabic{#1}}{1000}\formatNumber{\t}}

% Returns the spelled out number
% TODO: languages
\newcommand*{\spellout}[2]{
  \FPdiv{\intmoney}{\arabic{#1}}{1000}\FPtrunc{\res}{\intmoney}{0}\numberstringnum{\res}  % Integer amount
  \IfEqCase*{#2}{ % Currency
    {USD}{US dollars}%
    {EUR}{Euro}%
    {UAH}{Ukrainian hryvnia}%
    {RUB}{Russian roubles}%
    {CHF}{Swiss francs}%
    {PLN}{Polish zloty}%
    {CAD}{Canadian dollars}%
  }[Moneys]%
  \FPmul{\intmoney}{\res}{1000}\FPneg{\res}{\intmoney}\FPadd{\t}{\arabic{#1}}{\res} % Cent amount
  \FPdiv{\res}{\t}{10}\FPround{\t}{\res}{0}\t\ %
  \IfEqCase*{#2} { % Cent currency
    {USD}{cents}%
    {EUR}{eurocents}%
    {UAH}{kopiykas}%
    {RUB}{kopeykas}%
    {CHF}{cents}%
    {PLN}{groszy}%
    {CAD}{cents}%
  }
}

% Create an invoice table
\newenvironment{invoiceTable}{
    % Create a new row from title, unit quantity, unit rate, and unit name
    \newcommand*{\unitrow}[4]{%
         \addtocounter{feeordernum}{1}%
         \addtocounter{cost}{1000 * \real{##2} * \real{##3}}%
         \addtocounter{subcost}{1000 * \real{##2} * \real{##3}}%
         \arabic{feeordernum}. & ##1 & \formatNumber{##2} ##4 & \$\formatNumber{##3} & \$\FPmul{\cost}{##2}{##3}\formatNumber{\cost}%
         \\
    }
    % Create a new row from title and expense amount
    \newcommand*{\feerow}[2]{%
        \addtocounter{feeordernum}{1}%
         \addtocounter{cost}{1000 * \real{##2}}%
         \addtocounter{subcost}{1000 * \real{##2}}%
         \arabic{feeordernum}. & ##1 & & \$\formatNumber{##2} & \$\FPmul{\cost}{##2}{1}\formatNumber{\cost}%
         \\
    }

    \newcommand{\subtotalNoStar}{
        {\bf Subtotal} & {\bf \total{subhours} hours} &  & {\bf \$\total{subcost}}
        \setcounter{subcost}{0}
        \setcounter{subhours}{0}
        \\*[1.5ex]
    }
    \newcommand{\subtotalStar}{
        {\bf Subtotal} & & & {\bf \$\total{subcost}}
        \setcounter{subcost}{0}
        \\*[1.5ex]
    }
    \newcommand{\subtotal}{
         \hline
         \@ifstar
         \subtotalStar%
         \subtotalNoStar%
    }

    % Create a new row from date and hours worked (use stored fee type and hourly rate)
    \newcommand*{\hourrow}[3]{%
        \addtocounter{hours}{1000 * \real{##2}}%
        \addtocounter{subhours}{1000 * \real{##2}}%
        \unitrow{##1}{##2}{##3}{hours}%
    }
    \renewcommand{\tabcolsep}{0.8ex}
    \setlength\LTleft{0pt}
    \setlength\LTright{0pt}
    \begin{longtable}{@{\extracolsep{\fill}\hspace{\tabcolsep}} r l r r r }
    \hline
    {\bf №} & {\bf Description of Services} & \multicolumn{1}{c}{\bf Quantity} & \multicolumn{1}{c}{\bf Unit Price} & \multicolumn{1}{c}{\bf Amount} \\*
    \hline\hline
    \endhead
}{
    \hline\hline\hline
    & & & {\bf Total / Усього:}  & {\bf \$\total{cost}} \\
    {\bf To pay:} & \multicolumn{3}{l}{\spellout{cost}{USD}}\\
    {\bf До сплати:} & \multicolumn{3}{l}{\spellout{cost}{USD}}\\
    \end{longtable}
}

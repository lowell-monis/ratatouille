% This document class provides a simple memo for LaTeX users.
% It is based on article.cls and inherits most of the functionality
% that class.
% 
% Author: Rob Oakes, Copyright 2010.  Released under the LGPL, version 3.
% A copy of the LGPL can be found at http://www.gnu.org/licenses/lgpl.html
%
% Adapted by Alice Chen for Cornell INFO 1200 Information Ethics, Law, and Policy.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{texMemo}[2019/03/28 - Simple Memo Class]

% Load the Base Class
\LoadClassWithOptions{article}

% Begin Requirements
\RequirePackage{ifthen}

% Code added by Alice
\RequirePackage{mathptmx} % close to Times New Roman
\RequirePackage[utf8]{inputenc} % non-ascii characters such as \S
\RequirePackage[parfill]{parskip} % no indent, new line
\RequirePackage[document]{ragged2e} % left-justified
\RequirePackage{biblatex} % references: https://www.overleaf.com/learn/latex/Bibliography_management_in_LaTeX
\addbibresource{ref.bib}
\defbibheading{bibliography}{\textbf{References}}
\RequirePackage[hidelinks]{hyperref} % clickable link
\RequirePackage{titlesec} % section header font and spacing
\titleformat{\section}
  {\normalfont\bfseries}{\thesection}{.5em}{} 
\titlespacing{\section}{0pt}{10pt}{0pt}
\renewcommand\thesection{\Roman{section}.} % I., II., etc.

% Specialized memo Commands (To, From, Subject, Logo, Letterhead Address)

\def\@memoto{\relax}
\newcommand{\memoto}[1]{\gdef\@memoto{#1}}

\def\@memofrom{\relax}
\newcommand{\memofrom}[1]{\gdef\@memofrom{#1}}

\def\@memore{\relax}
\newcommand{\memore}[1]{\gdef\@memore{#1}}

\def\@memodate{\relax}
\newcommand{\memodate}[1]{\gdef\@memodate{#1}}

\def\@memosection{\relax}
\newcommand{\memosection}[1]{\gdef\@memosection{#1}}

\def\@letterheadaddress{\relax}
\newcommand{\lhaddress}[1]{\gdef\@letterheadaddress{#1}}

% Custom Document Formatting
\newcommand\decorativeline[1][1pt]{
	\par\noindent%
	\rule[0.5ex]{\linewidth}{#1}\par
}

% Set the Paper Size and margins
\RequirePackage{geometry}
\geometry{letterpaper, margin=1in}

% Create the Letterhead and To/From Block

\renewcommand{\maketitle}{\makememotitle}
\newcommand\makememotitle{
	% To, From, Subject Block
	\begin{description}
	    \setlength{\parskip}{0pt} % no new line in header
		\ifthenelse{\equal{\@memoto}{\relax}}{}{\item [{To:}] \@memoto}
		\ifthenelse{\equal{\@memofrom}{\relax}}{}{\item [{From:}] \@memofrom}
		\ifthenelse{\equal{\@memore}{\relax}}{}{\item [{Re:}] \@memore}
		\ifthenelse{\equal{\@memodate}{\relax}}{}{\item [{Date:}] \@memodate}
		\ifthenelse{\equal{\@memosection}{\relax}}{}{\item [{Section:}] \@memosection}
	\end{description}
	\decorativeline{}
}
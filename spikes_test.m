clear all

% instantiate spikes library
spikes = spikes_library();

% add neurons with spike trains, i.e., "words"
% add_words(obj, counts, mu, samps)
%   obj         spikes_library      spikes_library object
%   counts      array               number of spikes per word
%   mu          float/int           average firing rate of spike train
%   samps       int                 number of spike trains per count

add_words(spikes, 1:5, 5, 3);
add_words(spikes, 1:5, 7, 5);

% set up links using struct
links = {};
links.n1.s1.x1 = [ ...
    {'n2s1x1' 5}; ...
    {'n2s2x1' 3}; ...
    {'n2s3x1' 1}; ...
    {'n2s4x1' 1}; ...
    {'n2s5x1' 1}];
links.n1.s2.x1 = [ ...
    {'n2s1x2' 5}; ...
    {'n2s2x2' 3}; ...
    {'n2s3x2' 1}; ...
    {'n2s4x2' 1}; ...
    {'n2s5x2' 1}];
links.n1.s3.x1 = [ ...
    {'n2s1x3' 5}; ...
    {'n2s2x3' 3}; ...
    {'n2s3x3' 1}; ...
    {'n2s4x3' 1}; ...
    {'n2s5x3' 1}];
links.n1.s4.x1 = [ ...
    {'n2s1x4' 5}; ...
    {'n2s2x4' 3}; ...
    {'n2s3x4' 1}; ...
    {'n2s4x4' 1}; ...
    {'n2s5x4' 1}];
links.n1.s5.x1 = [ ...
    {'n2s1x5' 5}; ...
    {'n2s2x5' 3}; ...
    {'n2s3x5' 1}; ...
    {'n2s4x5' 1}; ...
    {'n2s5x5' 1}];

link_words(spikes, links);

G = show_graph(spikes);
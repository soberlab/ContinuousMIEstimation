classdef spikes_library < handle
    properties
        neurons % list of neurons
        words % struct of spike patterns
        adj_mat % adjacency matrix
    end
    
    methods
        function obj = spikes_library()
            % Constructor function
            obj.neurons = {};
            obj.words = {};
            obj.adj_mat = [];
        end
        
        function name = add_words(obj, counts, mu, samps)
            % Adds neuron with specified parameters
            %
            % obj       spikes_library object
            % counts    list of spike counts in spike trains
            % mu        average rate of Poisson process
            %           if one element, all spike trains have same mu
            %           if list, each element is matched to counts, samps
            %           for spike train
            %
            % samps     number of reptitions for each spike count
            % name      name of neuron, default 'n'
            
            
            if nargin < 4; samps = 1; end % default samp number = 1
            
            % Check format of samps against counts
            if (length(samps) ~= 1) & (length(samps) ~= length(counts))
                error('!! samps needs to be dim=1 or dim=dim(counts) !!');
            end
            
            name = ['n' num2str(length(obj.neurons)+1)]; % increment default neuron number
            
            % Generate words
            tmp_neurons = obj.neurons;
            tmp_words = obj.words;
            if length(mu) == 1 % use same firing rate for all spike trains
                for i=1:length(counts)
                    tmp_neurons.(name).(['s' num2str(counts(i))]) = {};
                    if length(samps) > 1
                        samp = samps(i); % if multiple samps provided, match samps to counts
                    else
                        samp = samps; % if one samps provided, use same for all counts
                    end
                    for j=1:samp
                        tmp_ts = exprnd(mu, 1, counts(i)); % generate Poisson process ISI
                        tmp_words.([name 's' num2str(counts(i)) 'x' num2str(j)]) = cumsum(tmp_ts); % calculate spike times
                        tmp_neurons.(name).(['s' num2str(counts(i))])(end+1) = {['x' num2str(j)]};
                    end
                end
            else
                if length(mu) == length(counts)*length(samps) % specify firing rate for each samp for each count
                    for i=1:length(counts)
                        if length(samps) > 1
                            samp = samps(i);
                        else
                            samp = samps;
                        end
                        
                        avg = mu(i);
                        
                        for j=1:samp
                            tmp_ts = exprnd(avg, 1, counts(i)); % generate Poisson process ISI
                            tmp_words.([name 's' num2str(counts(i)) 'x' num2str(j)]) = cumsum(tmp_ts); % calculate spike times
                        end
                    end
                else
                    error('!! mu needs to be of dim=1 or dim=dim(count)*dim(samps) !!');
                end
            end
            
            % Update adjacency matrix for new words
            if (sum(sum(obj.adj_mat)) > 0) & (size(obj.words) ~= 0)
                oldKeys = fieldnames(obj.words);
                newKeys = fieldnames(orderfields(tmp_words));
                adj_mat = obj.adj_mat;
                
                % instantiate temp adjacency matrix with same number of
                % columns as old adj_mat, but extend number of rows
                tmp_adj = zeros(size(newKeys,1), size(oldKeys,1));

                for i=1:size(oldKeys,1)
                    % update rows corresponding to old words
                    ix = find(strcmp(newKeys, oldKeys{i}));
                    tmp_adj(ix,:) = adj_mat(i,:);
                end
                
                for i=1:size(newKeys,1)
                    % insert columns corresponding to new words
                    ix = find(strcmp(oldKeys, newKeys{i}));
                    if length(ix) == 0
                        if i+1 < size(tmp_adj,2)
                            % insert columns into adjacency matrix
                            tmp_adj = [tmp_adj(:,1:i-1) zeros(size(tmp_adj,1),1) tmp_adj(:,i:end)];
                        else
                            % add columns to end of adjacency matrix
                            tmp_adj(:,end+1) = zeros(size(tmp_adj,1),1);
                        end
                    end
                end
            else
                tmp_adj = zeros(size(fieldnames(tmp_words),1));
            end
            
            obj.adj_mat = tmp_adj;
            obj.words = orderfields(tmp_words);
            obj.neurons = tmp_neurons;
        end
        
        function wordKey = get_words(obj)
            % Get word index
            wordKey = fieldnames(obj.words);
        end
        
        function link_words(obj, arrLinks)
            % Adds links between neuron spike patterns
            % Allow for an update using adjacency matrix OR...
            % Allow for an update by link name
            % Allow for an update by struct: neuron (field) >> count
            % (field) >> sample (array)
            if isstruct(arrLinks)
                disp('Updating adjacency matrix from struct...');
                
                keys = get_words(obj);
                neurons = fieldnames(arrLinks);
                for n=1:size(neurons,1) % get primary neuron
                    neuron = neurons{n};
                    counts = fieldnames(arrLinks.(neuron));
                    for c=1:size(counts,1) % get spike counts for primary neuron
                        count = counts{c};
                        samps = fieldnames(arrLinks.(neuron).(count));
                        for s=1:size(samps,1) % get sample number for spike count of primary neuron
                            samp = samps{s};
                            links = arrLinks.(neuron).(count).(samp);
                            for l=1:size(links,1) % get spike train to link to
                                row = find(strcmp(keys, [neuron count samp]));
                                col = find(strcmp(keys, links{l,1}));
                                obj.adj_mat(row,col) = links{l,2};
                            end
                        end
                    end
                end
                
            elseif ismatrix(arrLinks)
                disp("it's a matrix");
            end
        end
        
        function G = show_graph(obj)
            G = digraph(obj.adj_mat, get_words(obj), 'omitselfloops');
            h_graph = plot(G, 'EdgeLabel', G.Edges.Weight);

            nl = h_graph.NodeLabel;
            h_graph.NodeLabel = '';
            xd = get(h_graph, 'XData');
            yd = get(h_graph, 'YData');
            text(xd+0.2, yd-0.01, nl, 'FontSize', 12, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'Rotation', -45);
        end
        
        function show_words(obj)
            spike_ts = obj.words;
            keys = fieldnames(spike_ts);
            
            t_max = 0;
            max_len = 1;
            for i=1:length(keys)
                t_max = max(max(t_max, spike_ts.(keys{i})));
                max_len = max(max_len, length(spike_ts.(keys{i})));
            end
            
            t_max = t_max*1.25;

            samp_ts = nan(length(keys), max_len);            
            for i=1:length(keys)
                train = spike_ts.(keys{i});
                samp_ts(i,1:length(train)) = train;
            end
            
            fig = figure;
            axRaster = subplot(3,3,(1:6));
            axHist = subplot(3,3,(7:9));
            
            grid(axRaster, 'on');
            hold(axRaster, 'on');
            grid(axHist, 'on');
            hold(axHist, 'on');
            linkaxes([axRaster axHist], 'x');

            [n, m] = size(samp_ts);

            xs = repmat(reshape(samp_ts, 1,n*m), 2,1);
            ys = repmat(reshape(repmat((1:n)',1,m), 1,n*m), 2,1);
            ys(2,:) = ys(2,:) + 1;

            h_raster = plot(axRaster, xs, ys, 'k-');
            hold(axRaster, 'on');
            
            set(axRaster, 'YTick', 1:length(keys));
            set(axRaster, 'YTickLabels', keys);
            ylabel(axRaster, 'Word Name');

            ylim(axRaster, [0 n+1]);
            xlim(axRaster, [-5 t_max]);

            plot(axRaster, [0 0], axRaster.YLim, 'r--', 'LineWidth', 0.25);
            uistack(h_raster, 'top');
            
            h_hist = histogram(axHist, samp_ts);
            h_hist.BinEdges = (0:2:t_max);
            xlabel(axHist, 'Time (ms)');
            ylabel(axHist, 'Iteration');

            xlim(axHist, [-5 t_max]);
        end
        
    end    
end
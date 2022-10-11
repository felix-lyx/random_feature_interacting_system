function legend_name = get_legend_name_for_phis(sys_info, plot_info, type, k1, k2)
% function legend_name = get_legend_name_for_phis(sys_info, plot_info, type, k1, k2)

% (c) M. Zhong (JHU)

if sys_info.K > 1
  type_indicator = sprintf('_{%d%d}', k1, k2);
else 
  type_indicator = [];
end

switch type
  case 'phi'
    switch plot_info.phi_type
      case 'energy'
        if sys_info.ode_order == 1, legend_name = ['$g' type_indicator '$']; 
        else, legend_name = ['$g' type_indicator '$']; end
      case 'alignment'
        legend_name               = ['$g' type_indicator '$'];
      case 'xi'
        legend_name               = ['$\phi^{\xi}' type_indicator '$'];
      otherwise
    end    
  case 'phihat'
    if sys_info.K > 1
        type_indicator = sprintf(',%d%d', k1, k2);
    end
    switch plot_info.phi_type
      case 'energy'
        if sys_info.ode_order == 1, legend_name = ['$g_{N' type_indicator '}$']; 
        else, legend_name = ['$g_{N' type_indicator '}$']; end
      case 'alignment'
        legend_name               = ['$g_{N' type_indicator '}$'];
      case 'xi'
        legend_name               = ['$\hat\phi^{\xi}' type_indicator '$'];
      otherwise
    end     
  case 'phihatsmooth'
    switch plot_info.phi_type
      case 'energy'
        if sys_info.ode_order == 1, legend_name = ['$\phi^{\text{reg}}' type_indicator '$']; 
        else, legend_name = ['$\phi^{E, \text{reg}}' type_indicator '$']; end
      case 'alignment'
        legend_name               = ['$\phi^{A, \text{reg}}' type_indicator '$'];
      case 'xi'
        legend_name               = ['$\phi^{\xi, \text{reg}}' type_indicator '$'];
      otherwise
    end     
  otherwise
end
end
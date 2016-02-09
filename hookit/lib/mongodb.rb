
module Hooky
  module Mongodb

    BOXFILE_DEFAULTS = {
      # global settings
      before_deploy:                       {type: :array, of: :string, default: []},
      after_deploy:                        {type: :array, of: :string, default: []},

      # mongodb settings
      mongodb_objcheck:                    {type: :on_off, default: true},
      mongodb_log_verbosity:               {type: :string, default: '', from: ['', 'v', 'vv', 'vvv', 'vvvv', 'vvvvv']},
      monogdb_directoryperdb:              {type: :on_off, default: true},
      mongodb_logappend:                   {type: :on_off, default: true},
      mongodb_nojournal:                   {type: :on_off, default: false},
      mongodb_noscripting:                 {type: :on_off, default: false}
    }

  end
end

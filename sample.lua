
--[[

This file samples characters from a trained model

Code is based on implementation in 
https://github.com/oxford-cs-ml-2015/practical6

]]--

require 'torch'
require 'nn'
require 'nngraph'
require 'optim'
require 'lfs'
require 'csvigo'
require 'util.OneHot'
require 'util.misc'
local dbg = require("debugger.lua/debugger")
local utf8 = require("lua-utf8")
cmd = torch.CmdLine()
cmd:text()
cmd:text('Sample from a character-level language model')
cmd:text()
cmd:text('Options')
-- required:
cmd:argument('-model','model checkpoint to use for sampling')
-- optional parameters
cmd:option('-seed',123,'random number generator\'s seed')
cmd:option('-sample',1,' 0 to use max at each timestep, 1 to sample at each timestep')
cmd:option('-primetext',"",'used as a prompt to "seed" the state of the LSTM using a given sequence, before we sample.')
cmd:option('-length',2000,'number of characters to sample')
cmd:option('-temperature',1,'temperature of sampling')
cmd:option('-gpuid',0,'which gpu to use. -1 = use CPU')
cmd:option('-opencl',0,'use OpenCL (instead of CUDA)')
cmd:option('-verbose',1,'set to 0 to ONLY print the sampled text, no diagnostics')
cmd:option('-csvFile',"",'load csv file')
cmd:text()

-- parse input params
opt = cmd:parse(arg)

-- gated print: simple utility function wrapping a print
function gprint(str)
    if opt.verbose == 1 then print(str) end
end
--------------------------------------------------------------------
-- check that cunn/cutorch are installed if user wants to use the GPU
if opt.gpuid >= 0 and opt.opencl == 0 then
    local ok, cunn = pcall(require, 'cunn')
    local ok2, cutorch = pcall(require, 'cutorch')
    if not ok then gprint('package cunn not found!') end
    if not ok2 then gprint('package cutorch not found!') end
    if ok and ok2 then
        gprint('using CUDA on GPU ' .. opt.gpuid .. '...')
        gprint('Make sure that your saved checkpoint was also trained with GPU. If it was trained with CPU use -gpuid -1 for sampling as well')
        cutorch.setDevice(opt.gpuid + 1) -- note +1 to make it 0 indexed! sigh lua
        cutorch.manualSeed(opt.seed)
    else
        gprint('Falling back on CPU mode')
        opt.gpuid = -1 -- overwrite user setting
    end
end

-- Seed for random generator
torch.manualSeed(opt.seed)

-- load the model checkpoint
if not lfs.attributes(opt.model, 'mode') then
    gprint('Error: File ' .. opt.model .. ' does not exist. Are you sure you didn\'t forget to prepend cv/ ?')
end
checkpoint = torch.load(opt.model) -- save checkpoints
protos = checkpoint.protos
protos.rnn:evaluate() -- put in eval mode so that dropout works properly

-- initialize the vocabulary (and its inverted version)
local vocab = checkpoint.vocab
local ivocab = {}
for c,i in pairs(vocab) do ivocab[i] = c end
print("We are now inside the debugger")
-- initialize the rnn state to all zeros
gprint('creating an ' .. checkpoint.opt.model .. '...')
local current_state
current_state = {}
for L = 1,checkpoint.opt.num_layers do
    -- c and h for all layers
    local h_init = torch.zeros(1, checkpoint.opt.rnn_size):double()
    if opt.gpuid >= 0 and opt.opencl == 0 then h_init = h_init:cuda() end
    if opt.gpuid >= 0 and opt.opencl == 1 then h_init = h_init:cl() end
    table.insert(current_state, h_init:clone())
    if checkpoint.opt.model == 'lstm' then
        table.insert(current_state, h_init:clone())
    end
end
state_size = #current_state
local seed_text = ''
-- do a few seeded timesteps What are seeded timesteps
local csv_table = csvigo.load({path = opt.csvFile, mode = 'large'})
for j=1, 100 do 
        seed_text = csv_table[j+1][1] .. ','
        io.write(csv_table[j+1][1] .. ',')
        if string.len(seed_text) > 0 then
                for c in seed_text:gmatch'.' do
                        prev_char = torch.Tensor{vocab[c]}
                        if opt.gpuid >= 0 and opt.opencl == 0 then prev_char = prev_char:cuda() end
                        if opt.gpuid >= 0 and opt.opencl == 1 then prev_char = prev_char:cl() end
                        -- produces output from prev_char and the current_state
                        -- The output is a probability distribution over the characters
                        -- By current_state we mean the set of states which produce the output 
                        local lst = protos.rnn:forward{prev_char, unpack(current_state)}
                        -- lst is a list of [state1,state2,..stateN,output]. We want everything but last piece
                        current_state = {}
                        for i=1,state_size do table.insert(current_state, lst[i]) end
                        prediction = lst[#lst] -- last element holds the log probabilities
                end
        end
        endToken = ""
        --start sampling/argmaxing
        while endToken ~= '\n' do
        -- log probabilities from the previous timestep
                if opt.sample == 0 then
                -- use argmax
                        local _, prev_char_ = prediction:max(2) --
                        prev_char = prev_char_:resize(1)
                else
                        dbg()
                        prediction:div(1) -- scale by temperature
                        probs = torch.exp(prediction):squeeze()
                        probs:div(torch.sum(probs)) -- renormalize so probs sum to one
                        prev_char = torch.multinomial(probs:float(), 1):resize(1):float()
                end
                -- forward the rnn for next character
                local lst = protos.rnn:forward{prev_char, unpack(current_state)}
                current_state = {}
                for i=1,state_size do table.insert(current_state, lst[i]) end
                prediction = lst[#lst] -- last element holds the log probabilities
                endToken = ivocab[prev_char[1]]
                io.write(ivocab[prev_char[1]])
        end
end
io.write('\n') io.flush()

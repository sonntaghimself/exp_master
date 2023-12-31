"""
This experiment is to be a first draft of the experiment we will be implementing
for our Masters Thesis.

Congruency will be manipulated through the Congruency of movement direction and
color. participants have to respond to each with a key press.

A prime before the trial indicates which target dimension is relevant for the
following trial.

As DV, at this point, only Reaction time (and error commission) are recorded.

To start with, helpers will be imported and the participant information stored
in a seperate file (order will be randomized to assure anonymity)

new response keys: t & v

In accordance with prior research, we chose .25 and .75 as coherence for  the
movement task.

We chose 62.5% and 87.5% for the color task, since mathematically argued, the
amount of evidence is equivalent to the movement task.

The same train of thought was also applied to the coherence/proportion in the
distractor condition. the 90% for the color task were adjusted to it's
equivalent in the direction task.

estimated duration: 
(144 * 10 * (0.75 + (0.2 * .75) + 0.5 + 0.5)) / 60
~ 45.6 Minutes

UPDATE: since VP 6 took about 3.5 seconds per trial; we have to drastically
adjust the number of trials.

With 96, we should get ~56 minutes. Since incremental saving is now implemented,
we'll go ahead with this duration.
"""

from psychopy import visual, event, core
import datetime as dt
import pandas as pd
import helpers

########################
#   global variables   #
########################
parameters = {
    # have fix with task around it; 0.75 seconds, 0.75 error feedback
    # "time": {"fix": 0.75, "feedback": 0.75, "iti": 0.5, "task": 1, "pres": 3},
    "time": {"fix": 0.75, "feedback": 0.75, "iti": 0.5, "pres": 3},
    "keys": ["t", "v"],
    "start_key": "space",
    "dotsize": 35,
    "ndots": 200,
    "text_size": 35,
    "taskname": {"color": "Farbe", "direction": "Richtung"},
    "proportions": {
        "color": {"hard": 0.625, "easy": 0.875},
        "direction": {"hard": 0.25, "easy": 0.75},
        "distractor": {"color": 0.90, "direction": 0.8},
    },
    "color": {
        "col_1": [5, 137, 255],
        "col_2": [255, 65, 2],
    },  # These values are adpated from Kayser et al. (2010)
    # "color": {"col_1": [-1, -1, 1], "col_2": [1, -1, -1]},
    "dir": {"up": 90, "down": 270},
    "dist_dir": {"up": 270, "down": 90},
    "colnames": {"col_1": "blau", "col_2": "rot"},
    "cor_resp_dir": {"up": "t", "down": "v"},
}

parameters["dist_col"] = {
    "col_1": parameters["color"]["col_2"],
    "col_2": parameters["color"]["col_1"],
}

# parameters["StimNum"] = helpers.StimNum(parameters)

########################
#    vp information    #
########################
vp_info = helpers.gather_information()

########################
#       Stimuli        #
########################
dir = ["up", "down"]
col = ["col_1", "col_2"]
tsk = ["color", "direction"]
dif = ["easy", "hard"]
stimuli = [
    [direction, color, task, difficulty]
    for direction in dir
    for color in col
    for task in tsk
    for difficulty in dif
]

"""
the response mapping is assigned here.
Following, the correct color names to the corresponding response keys are saved 
to parameters, to make the instruction generation less of a headache.
"""

if vp_info["vp_num"] % 2 == 0:
    parameters["cor_resp_col"] = {
        "col_1": parameters["keys"][0],
        "col_2": parameters["keys"][1],
    }

    parameters["cor_col_resp"] = {
        parameters["keys"][0]: parameters["colnames"]["col_1"],
        parameters["keys"][1]: parameters["colnames"]["col_2"],
    }
else:
    parameters["cor_resp_col"] = {
        "col_1": parameters["keys"][1],
        "col_2": parameters["keys"][0],
    }

    parameters["cor_col_resp"] = {
        parameters["keys"][0]: parameters["colnames"]["col_2"],
        parameters["keys"][1]: parameters["colnames"]["col_1"],
    }

for stim in stimuli:
    if stim[2] == "color":
        stim.append(parameters["cor_resp_col"][stim[1]])
    elif stim[2] == "direction":
        stim.append(parameters["cor_resp_dir"][stim[0]])
    if parameters["cor_resp_dir"][stim[0]] == parameters["cor_resp_col"][stim[1]]:
        stim.append("congruent")
    else:
        stim.append("incongruent")


min_len = len(stimuli)  # how long a block has to be at least for a full stim repetition

if vp_info["version"] == "full":
    parameters["num"] = {
        "nblks": 10,
        "pracblks": 2,
        "nprac": int(2 * min_len),
        "ntrls": int(7 * min_len),
    }
    parameters["exp_len"] = 12
elif vp_info["version"] == "test":
    parameters["num"] = {
        "nblks": 2,
        "pracblks": 0,
        "nprac": min_len,
        "ntrls": min_len,
    }
    parameters["exp_len"] = 2

########################
#     import files     #
########################
files = helpers.my_files(vp_info)

########################
#      Trial Seq       #
########################
exp = helpers.randomisation(stimuli, vp_info, parameters, files)

########################
#     Instructions     #
########################
inst_text = helpers.read_instructions(files, parameters)

########################
#       Psychopy       #
########################
win = visual.Window(color=(0, 0, 0), fullscr=True, units="pix")
myScreenSizeX = win.size[0]
myScreenSizeY = win.size[1]
if win.useRetina:  # conditionally adjusting for pixel size on Retina
    myScreenSizeX *= 0.5
    myScreenSizeY *= 0.5

my_mouse = event.Mouse(visible=False)
frame_rate = win.getActualFrameRate(
    nIdentical=60, nMaxFrames=100, nWarmUpFrames=10, threshold=1
)

if frame_rate is None:  # failsafe for mac.
    frame_rate = 120

timer = core.Clock()
inst_stim = visual.TextStim(
    win,
    text=inst_text["inst_1"],
    alignText="center",
    # alignText="left",
    wrapWidth=(0.75 * myScreenSizeX),
    # bold=True,
    height=parameters["text_size"],
)
fb_stim = visual.TextStim(win, height=parameters["text_size"])
BlkStim = visual.TextStim(
    win, height=parameters["text_size"], wrapWidth=(0.75 * myScreenSizeX)
)
task_stim_0 = visual.TextStim(win, height=parameters["text_size"])
task_stim_1 = visual.TextStim(win, height=parameters["text_size"])
fix_stim = visual.ShapeStim(
    win,
    lineWidth=2,
    lineColor="white",
    pos=(0, 0),
    vertices=((-10, 0), (10, 0), (0, 0), (0, 10), (0, -10)),
    closeShape=False,
)

task_stim_0.pos = (0, inst_stim.height)
task_stim_1.pos = (0, -(inst_stim.height))

fix_list = [fix_stim, task_stim_0, task_stim_1]

stim_gen = parameters
########################
#      Trial Loop      #
########################
for blk in exp:
    blk = [x for x in blk if x]  # making sure no faulty values are passed through

    if blk[0]["blk"] == 1:  # Instructions for the first block
        for inst in range(1, 3):
            inst_stim.text = inst_text["inst_" + str(inst)]
            inst_stim.draw()
            win.flip()
            event.waitKeys()
        for inst in range(3, 5):  # We combine two files for this screen
            inst_stim.text = inst_text["inst_" + str(inst)]
            if inst < 4:
                inst_stim.pos = (0, myScreenSizeY / 5)
            else:
                inst_stim.pos = (0, -(myScreenSizeY / 5))
            inst_stim.draw()
        win.flip()
        event.waitKeys()

    BlkStim.text = helpers.block_screen(True, blk, parameters, files)
    # True as positional argument, when Block Start Screen is needed
    BlkStim.draw()
    win.flip()
    event.waitKeys()

    for trl in blk:
        task_stim_0.text = task_stim_1.text = parameters["taskname"][trl["task"]]
        for _ in range(int(parameters["time"]["fix"] * frame_rate)):
            for item in fix_list:
                item.draw()
            win.flip()

        """
        color difficulty manipulation is taken care of through the generation of
        two identical sets of visual.DotStim stimuli.

        One with the relevant, one with the irrelevant color.

        nStim is therefore determined by the current difficulty.

        for the direction task, the built-in function coherence is used.
        """

        if trl["task"] == "direction":
            n_stim = (
                parameters["proportions"]["distractor"]["color"] * parameters["ndots"]
            )
            my_coherence = parameters["proportions"][trl["task"]][trl["difficulty"]]

        elif trl["task"] == "color":
            n_stim = (
                parameters["proportions"][trl["task"]][trl["difficulty"]]
                * parameters["ndots"]
            )
            my_coherence = parameters["proportions"]["distractor"]["direction"]

        dots_stim = visual.DotStim(
            win,
            colorSpace="rgb255",
            dotSize=10,
            coherence=my_coherence,
            dotLife=-1,
            speed=1.5,
            units="pix",
            fieldSize=[myScreenSizeY / 2, myScreenSizeY / 2],
            nDots=int(n_stim),
            fieldShape="circle",
        )

        dots_stim_alt = visual.DotStim(
            win,
            colorSpace="rgb255",
            dotSize=10,
            coherence=my_coherence,
            dotLife=-1,
            speed=1.5,
            units="pix",
            fieldSize=[myScreenSizeY / 2, myScreenSizeY / 2],
            nDots=int(parameters["ndots"] - n_stim),
            fieldShape="circle",
        )

        dots_stim.color = parameters["color"][trl["color"]]
        dots_stim.dir = dots_stim_alt.dir = parameters["dir"][trl["direction"]]
        dots_stim_alt.color = parameters["dist_col"][trl["color"]]

        event.clearEvents()
        trl_complete = False

        win.callOnFlip(timer.reset)

        frames = 0
        slow = False

        while not trl_complete:
            dots_stim.draw()
            dots_stim_alt.draw()
            win.flip()
            frames += 1
            keys = []
            keys = event.getKeys()
            if keys:
                rt = timer.getTime()
                if trl["cor_resp"] in keys:
                    corr = 1
                else:
                    corr = 0
                    fb_stim.text = "FALSCH"
                trl_complete = True

            elif frames >= int((parameters["time"]["pres"] * frame_rate)):
                rt = timer.getTime()
                fb_stim.text = "Too slow"
                trl_complete = True
                corr = 2
                slow = True

        trl["date"] = dt.datetime.now().strftime("%d-%m-%Y-%H:%M:%S")
        trl["rt"] = rt
        trl["corr"] = corr

        if "escape" in keys:
            break

        if corr != 1:
            for _ in range(int(parameters["time"]["feedback"] * frame_rate)):
                fb_stim.draw()
                win.flip()

        for _ in range(int(parameters["time"]["iti"] * frame_rate)):
            win.flip()

    # Making sure that Results are saved, even if escape is pressed
    if "escape" in keys:
        break

    # generating end of block feeback, False is therefore passed as first
    # positional argument.
    BlkStim.text = helpers.block_screen(False, blk, parameters, files)
    BlkStim.draw()
    win.flip()
    event.waitKeys()

    # blank screen for inter-trial-interval
    for _ in range(int(parameters["time"]["iti"] * frame_rate)):
        win.flip()

########################
#         Data         #
########################
tmp_data = [trial for data in exp for trial in data if trial]
dataDF = pd.DataFrame()
dataDF = dataDF.from_dict(tmp_data)
dataDF.to_csv(files["resfile"], header=True, index=False, sep=",", mode="w")


end_text = "The Experiment is done, thank you for participating"

# end_text = end_text + "\n\n may the force be with you."

end_text = end_text + "\n\n press any key to end the experiment."

fb_stim.text = end_text
fb_stim.draw()
win.flip()
event.waitKeys()

# close window and quit
win.close()
core.quit()

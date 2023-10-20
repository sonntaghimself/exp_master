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
"""

from psychopy import visual, event, core, gui
import datetime as dt
import pandas as pd
import random
import helpers

########################
#   global variables   #
########################
parameters = {
    "time": {"fix": 30, "feedback": 50, "iti": 30, "task": 30, "pres": 200},
    "keys": ["s", "l"],
    "start_key": "space",
    "dotsize": 50,
    "ndots": 100,
    "proportions": {"large": 0.85, "small": 0.70},
    "color": {"col_1": [0, 1, 0], "col_2": [1, 0, 0]},
    "dist_col": {"col_1": [1, 0, 0], "col_2": [0, 1, 0]},
    "shape": ["tri", "circ"],
    "dist_shape": {"tri": "circ", "circ": "tri"},
}

########################
#    vp information    #
########################
vp_info = helpers.gather_information()

if vp_info["version"] == "full":
    parameters["num"] = {"nblks": 10, "pracblks": 2, "nprac": 16, "ntrls" : 40}
elif vp_info["version"] == "test":
    parameters["num"] = {"nblks": 2, "pracblks": 0, "nprac": 8, "ntrls" : 8}
# NOTE: since we have 4 stimuli (and two tasks), the #of trials has to be divisible by 8 (& >= 8)

########################
#       Stimuli        #
########################
shapes = parameters["shape"]
col = ["col_1", "col_2"]
tsk = ["color", "shape"]
stimuli = [
    [shape, color, task] for shape in shapes for color in col for task in tsk
]
print(stimuli)

# TODO: completely balance responses
if vp_info["vp_num"] % 2:
    parameters["cor_resp_col"] = {"col_1": "s", "col_2": "l"}
    parameters["cor_resp_sha"] = {parameters["shape"][0]: "s", 
                                  parameters["shape"][1]: "l"}
else:
    parameters["cor_resp_col"] = {"col_1": "l", "col_2": "s"}
    parameters["cor_resp_sha"] = {parameters["shape"][1]: "s", 
                                  parameters["shape"][0]: "l"}

for stim in stimuli:
    if stim[2] == "color":
        stim.append(parameters["cor_resp_col"][stim[1]])
    elif stim[2] == "shape":
        stim.append(parameters["cor_resp_sha"][stim[0]])
    if parameters["cor_resp_sha"][stim[0]] == parameters["cor_resp_col"][stim[1]]:
        stim.append("congruent")
    else:
        stim.append("incongruent")

########################
#     import files     #
########################
files = helpers.my_files(vp_info)

# Storing demographics
helpers.demographics(vp_info, files)

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
win = visual.Window(size=(1280, 800), color=(0, 0, 0), units="pix")
timer = core.Clock()
inst_stim = visual.TextStim(win, text=inst_text["inst"], alignText="center",
                            wrapWidth=(0.75*win.size[0]))
fb_stim = visual.TextStim(win)
task_stim = visual.TextStim(win)
fix_stim = visual.ShapeStim(
    win,
    lineWidth=2,
    lineColor="white",
    pos=(0, 0),
    vertices=((-10, 0), (10, 0), (0, 0), (0, 10), (0, -10)),
    closeShape=False,
)

dots_stim = visual.DotStim(
    win, dotSize=10, coherence=1, dotLife=-1, speed=0, units="pix",
    fieldSize=win.size/4,
    element = visual.Polygon(edges = 3),
    nDots = int((parameters["ndots"]*parameters["proportions"]["small"])/2),
    fieldShape = "circle"
)
dots_stim_alt = visual.DotStim(
    win, dotSize=10, coherence=1, dotLife=-1, speed=0, units="pix",
    fieldSize=win.size/4,
    nDots = dots_stim.nDots,
    fieldShape = "circle"
)
dots_dist = visual.DotStim(
    win, dotSize=10, coherence=1, dotLife=-1, speed=0, units="pix",
    fieldSize=win.size/4, nDots = int((parameters["ndots"]-dots_stim.nDots)/2),
    fieldShape = "circle"
)
dots_dist_alt = visual.DotStim(
    win, dotSize=10, coherence=1, dotLife=-1, speed=0, units="pix",
    fieldSize=win.size/4, nDots = dots_dist.nDots,
    fieldShape = "circle"
)

########################
#      Trial Loop      #
########################
for blk in exp:
    blk = [x for x in blk if x] # making sure no faulty values are passed through

    if blk[0]["blk"] == 1:
        inst_stim.draw()
        win.flip()
        event.waitKeys(keyList=parameters["start_key"])

    for trl in blk:
        task_stim.text = trl["task"]
        for _ in range(parameters["time"]["task"]):
            task_stim.draw()
            win.flip()
        for _ in range(parameters["time"]["fix"]):
            fix_stim.draw()
            win.flip()

        dots_stim.color = parameters["color"][trl["color"]]
        dots_stim.dir = parameters["dir"][trl["direction"]]
        dots_stim_alt.color = parameters["dist_col"][trl["color"]]
        dots_stim_alt.dir = parameters["dir"][trl["direction"]]
        dots_dist.color = parameters["dist_col"][trl["color"]]
        dots_dist.dir = parameters["dist_dir"][trl["direction"]]
        dots_dist_alt.color = parameters["color"][trl["color"]]
        dots_dist_alt.dir = parameters["dist_dir"][trl["direction"]]

        win.callOnFlip(timer.reset)

        event.clearEvents()
        trl_complete = False

        frames = 0
        slow = False

        while not trl_complete:
            dots_stim.draw()
            dots_dist.draw()
            dots_dist_alt.draw()
            dots_stim_alt.draw()
            win.flip()
            frames += 1
            keys = []
            keys = event.getKeys()
            if keys:
                rt = timer.getTime()
                if trl["cor_resp"] in keys:
                   corr = 1
                   fb_stim.text = "Correct"
                else:
                   corr = 0
                   fb_stim.text = "Incorrect"
                trl_complete = True

            if frames >= parameters["time"]["pres"]:
                rt = timer.getTime()
                fb_stim.text = "Too slow"
                trl_complete = True
                corr = 0
                slow = True

        if "escape" in keys:
            break

        for _ in range(parameters["time"]["feedback"]):
            fb_stim.draw()
            win.flip()

        trl["date"] = dt.datetime.now().strftime("%d-%m-%Y-%H:%M:%S")
        trl["rt"] = rt
        trl["corr"] = corr

        for _ in range(parameters["time"]["iti"]):
            win.flip()

    # generating end of block feeback
    blk_num = blk[0]["blk"]
    num_trls = len(blk)
    corr = [x["corr"] for x in blk]
    blk_per = (corr.count(1) / num_trls) * 100

    fb_txt = "Block {} of {}, \n Correct: {}%".format(blk_num, len(exp), blk_per)
    fb_txt = fb_txt + "\n\nPress the spacebar to continue."
    fb_stim.text = fb_txt
    fb_stim.draw()
    win.flip()
    event.waitKeys(keyList=[parameters["start_key"]])

    # blank screen for inter-trial-interval
    for _ in range(parameters["time"]["iti"]):
        win.flip()

########################
#         Data         #
########################
tmp_data = [trial for data in exp for trial in data if trial]
dataDF = pd.DataFrame()
dataDF = dataDF.from_dict(tmp_data)
dataDF.to_csv(files["resfile"], header=True, index=False, sep=",", mode="w")


end_text = "The Experiment is done, thank you for participating"

end_text = end_text + "\n\n may the force be with you."

end_text = end_text + "\n\n press any key to end the experiment."

fb_stim.text = end_text
fb_stim.draw()
win.flip()
event.waitKeys()

# close window and quit
win.close()
core.quit()

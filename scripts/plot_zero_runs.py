import matplotlib.pyplot as plt
import matplotlib.dates as mdates

def plot_zero_runs(df, figsize):

    # copy data
    zr = df.copy()

    # extract elements
    cats = sorted(zr['counter_id'].dropna().unique())

    # set up plot
    fig, ax = plt.subplots(figsize=figsize)
    ax.barh(zr['y'], zr['width'], left=zr['start_num'], height=0.8)

    ax.set_yticks(range(len(cats)))
    ax.set_yticklabels(cats)
    ax.xaxis_date()
    ax.xaxis.set_major_locator(mdates.AutoDateLocator())
    ax.xaxis.set_major_formatter(mdates.ConciseDateFormatter(ax.xaxis.get_major_locator()))
    ax.set_xlabel("Date")
    ax.set_ylabel("counter_id")
    ax.set_title("Zero-count days runs")

    ax.grid(True, axis='x', linestyle='--', alpha=0.3)
    plt.tight_layout()
    plt.show()

import pandas as pd
import matplotlib.dates as mdates


def compute_zero_runs(df, min_run_days):  

    # compute daily counts at each counter
    daily_counts = (
        df
        .groupby(['year', pd.Grouper(key='date_time_dt', freq='D'), 'site_id', 'counter_id'])['count']
        .sum()
        .reset_index()
    )

    # filter to days with zero counts
    zeros = daily_counts[daily_counts['count'] == 0].copy()
    zeros = zeros.sort_values(['counter_id', 'date_time_dt'])

    # use local calendar day
    zeros['day'] = zeros['date_time_dt'].dt.date

    # calculate runs
    zeros['run_id'] = (
        zeros.groupby('counter_id')['day']
            .diff()
            .ne(pd.Timedelta(days=1))
            .cumsum()
    )

    zero_runs = (
        zeros.groupby(['counter_id', 'run_id'])
            .agg(
                start=('day', 'min'),
                end=('day', 'max'),
                n_days=('day', 'size')
            )
            .reset_index()
    )

    # define min_run_days
    min_run_days= min_run_days

    # copy data
    zr = zero_runs.copy()

    # filter
    zr = zr[zr['n_days'] >= min_run_days]
    
    # convert to matplotlib date numbers and compute bar widths in days
    zr['start_num'] = mdates.date2num(zr['start'])
    zr['end_num']   = mdates.date2num(zr['end'])
    zr['width']  = zr['end_num'] - zr['start_num'] + 1 

    # y positions
    order = (zr.groupby('counter_id')['n_days'].sum().sort_values(ascending=False).index)
    zr['counter_id'] = pd.Categorical(zr['counter_id'], categories=order, ordered=True)
    cats = sorted(zr['counter_id'].dropna().unique())
    y_map = {cid: i for i, cid in enumerate(cats)}
    zr['y'] = zr['counter_id'].map(y_map)
    return zr
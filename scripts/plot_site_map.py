import pandas as pd
import folium

def plot_site_map(df):

    # establish map
    m = folium.Map(
        location=[df["lat_r"].mean(), df["lon_r"].mean()],
        zoom_start=12,
        tiles="cartodb positron",
        min_zoom=12,
        max_zoom=17,
        max_bounds=True
    )

    # set map bounds
    bounds = [
        [df["lat_r"].min() - 0.007, df["lon_r"].min() - 0.007],
        [df["lat_r"].max() + 0.007, df["lon_r"].max() + 0.007],
    ]

    m.fit_bounds(bounds)
    m.options["maxBounds"] = bounds
    m.options["maxBoundsViscosity"] = 1.0 

    # plot points
    for _, r in df.iterrows():
        folium.CircleMarker(
            location=[r["lat_r"], r["lon_r"]],
            radius=5,
            fill=True,
            fill_opacity=0.8,
            color="royalblue",
            weight=1,
        ).add_to(m)

    # compute site lat/lon centroids for labels
    sites = (
        df.groupby("site_name", as_index=False)
          .agg(lat=("lat_r", "mean"), lon=("lon_r", "mean"))
    )

    # add site labels
    label_lat_offset = -0.0006  

    for _, r in sites.iterrows():
        folium.Marker(
            location=[r["lat"] + label_lat_offset, r["lon"]],
            icon=folium.DivIcon(
            icon_size=(135, 20), 
            icon_anchor=(0, 0),
            html=f"""
            <div style="
                font-size: 14px;
                font-weight: bold;
                color: black;
                background-color: rgba(255,255,255,0.8);
                padding: 2px 6px;
                white-space: nowrap;
            ">
                {r["site_name"]}
            </div>
            """
        )
        ).add_to(m)

    return m